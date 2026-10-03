# Plan: TrueNAS CSI driver (iSCSI + NFS) on the cluster

Status: **ready to install, nothing deployed yet.** TrueNAS is on 25.10.7, the iSCSI and NFS services run and start at
boot, the API key authenticates over the WebSocket API (checked), and `values.yaml` + the rendered `truenas-csi.yaml`
pass a server-side dry-run. Phases 0-1 are done except creating the parent datasets if the driver needs them (see
README); next is phase 3 (apply) and phase 5 (smoke test + benchmark).

Driver: [truenas/truenas-csi](https://github.com/truenas/truenas-csi) (official, GPL-3.0). Talks to TrueNAS over the
WebSocket API (`wss://<host>/api/current`), so it is not affected by the REST API deprecation that breaks
democratic-csi's `freenas-api-*` drivers on 25.04.

## Why

fio on 2026-10-03 (4k write with fsync, the database case): Rook ~50 IOPS / 17.7 ms median ack, TrueNAS NFS ~1,360
IOPS / 0.7 ms. The TrueNAS pool (hardware RAID6, 1 GB controller cache, `sync=standard`) acknowledges sync writes from
the controller cache. iSCSI zvols on the same pool should keep that latency and give real block semantics (no NFS
locking trouble). Goal: dynamically provisioned fast block storage, one default class unchanged (`rook-ceph-block`),
databases opt in with a `storageClassName`.

## What is already in place (checked 2026-10-03)

| Requirement | State |
|---|---|
| Kubernetes >= 1.26 | v1.35.6 |
| `open-iscsi` on every node | present on kubenode1-5 |
| Mount propagation of `/` is `shared` (microk8s) | `shared:1` on all nodes |
| Kubelet path | `/var/snap/microk8s/common/var/lib/kubelet` (same as csi-driver-nfs) |
| NFS client on every node | present (kubenode5 fixed) |
| VolumeSnapshot CRDs + snapshot-controller | **not installed** (needed for snapshots/backups) |
| TrueNAS iSCSI service (port 3260) | off; enable after upgrade |

## Phases

0. **TrueNAS upgrade to 25.10.** Take a config backup and a ZFS snapshot of `Main/K8sData` first. Expect a short NFS
   interruption; check MySQL, Valkey, Redis and Gitea afterwards.
1. **TrueNAS prep.** Enable the iSCSI service; confirm the WebSocket API on 443; create an API key (the driver
   docs say it needs administrative privileges, so use a dedicated user if the UI allows); create the parent
   dataset the driver will use (`datasetPath`, e.g. `k8s`).
2. **Cluster prep.** Install the external-snapshotter CRDs + snapshot-controller (also gives Rook snapshots).
   Namespace `truenas-csi`; the API key goes into a Secret that is not committed.
3. **Install the driver** with Helm (`truenas.url`, `truenas.defaultPool=Main`, `insecureSkipTLS=true` until the UI
   has a trusted certificate). Follow the repo convention: `values.yaml` + rendered `truenas-csi.yaml` here, applied
   with `kubectl`. Set the kubelet path for microk8s.
4. **StorageClasses (non-default):**
   - `truenas-iscsi`: `protocol: iscsi`, `pool: Main`, `datasetPath: k8s/iscsi`, `compression: lz4`,
     `sync: standard`, `sparse: true`, `volblocksize: 16K` (matches MySQL/InnoDB pages; use 8K for Postgres-only
     classes if wanted), `allowVolumeExpansion: true`.
   - `truenas-nfs` (optional): same driver for RWX shares so one driver replaces `csi-driver-nfs`; decide after
     the iSCSI path is proven. Keep `nfs-csi-default` untouched until then.
   - A `VolumeSnapshotClass`, plus `snapshot.schedule`/`snapshot.retention` on classes that want automatic
     snapshots.
5. **Smoke test + benchmark.** Provision a PVC, mount it, then rerun the exact fio workloads used on 2026-10-03
   (fsync 4k qd1, rand 4k qd16, mixed 70/30, seq 1m) against `truenas-iscsi` so it is comparable to the Rook/NFS
   numbers. Proceed only if fsync latency stays well under Rook's.
6. **Migrate, one workload at a time** (stop app, copy data, repoint, verify, delete old PVC; old PVC kept until
   verified): 1) `spinnaker/mysql-pv-spinnaker` (NFS), 2) Valkey/Redis (`spinnaker/valkey`, Gitea valkey, harness
   redis-sentinel), 3) Gitea PostgreSQL (3 replicas, Rook), 4) the harness databases (200 Gi each; copy time
   depends on the network), 5) leave ClickHouse/Prometheus on Rook unless they show slow merges/compaction.
7. **Backups.** With snapshots available, schedule CSI snapshots for the migrated databases and rely on ZFS
   snapshots/replication on TrueNAS. This is the answer to Rook `size: 1` having no redundancy.

## Decisions (from the owner, 2026-10-03)

- **One driver for everything.** Use the TrueNAS CSI driver for both iSCSI (RWO block) and NFS (RWX), and retire
  `csi-driver-nfs` once the existing NFS volumes have moved. Decision gate in phase 5: the smoke test must include a
  non-root pod writing to an NFS and an iSCSI volume, because the driver docs show per-volume NFS shares with a
  `nfs.hosts` allow-list and `nfs.rootSquash`, but say nothing about dataset ownership/mode. If permissions are not
  better than today's `mountPermissions: 0777` approach, keep `csi-driver-nfs` for RWX.
- **Network is 1 GbE between the nodes and TrueNAS today; 10 GbE is planned.** See "Network" below.
- **The RAID controller battery is of unknown health** (used hardware). See "Cache safety" below.

## Network (1 GbE)

- A 1 GbE link tops out near 110 MB/s, shared by every NFS and iSCSI volume plus other node traffic. Database
  workloads are latency-bound (8,000 4k IOPS is only ~32 MB/s), so they fit; bulk copies and big sequential writes
  will saturate it.
- Moving the 200 Gi harness volumes is best-case ~35 minutes each at line rate, realistically 1-2 hours and slower
  while other traffic runs. Prefer the application's own replication (MongoDB replica set) to rebuild one member at a
  time online, and do the large copies in a maintenance window.
- When 10 GbE arrives, nothing in the driver config changes (same portal address); expect the NFS sequential-write
  tail latency to improve. Enabling jumbo frames end to end would help but is optional.
- Consider a separate VLAN/interface for storage traffic if the Proxmox bridge shares one NIC with everything else.

## Cache safety (RAID battery of unknown health)

- NFS fsync measured ~0.7 ms on spinning RAID6, which means the controller is acknowledging from write-back cache
  right now. That is safe only if the cache is protected. A controller normally falls back to write-through
  (slow, safe) when the battery is bad, unless it is set to "force write-back", which is the unsafe case.
- Before putting databases on this pool: check the controller's battery/capacitor status and cache policy in its
  management tool (or the server's BMC/iLO), confirm the policy is "write-back with BBU" and not "always/force
  write-back", and replace the battery if it is degraded. Add a battery-status alert when practical.
- If the battery cannot be trusted, the safe options are write-through (expect fsync latency to rise toward Rook's),
  a small SSD SLOG for the pool, or a replacement battery/controller.
- Either way, database volumes get scheduled CSI snapshots plus ZFS replication (phase 7); snapshots do not protect
  against a controller losing cached writes, so keep an off-box backup of anything irreplaceable.

## Other risks

- TrueNAS becomes a single point of failure for every database that moves: pods hang if it is down or rebooting.
  (Rook `size: 1` has the same property per node/OSD.) Schedule TrueNAS maintenance accordingly.
- ZFS sits on one hardware volume: it detects corruption but cannot self-heal; RAID6 provides redundancy. For
  irreplaceable datasets consider `copies=2`.
- IPv4 portals only (driver limitation); fine for this network.
- The driver creates UUID-named datasets/targets; do not edit them by hand.

## Open questions

1. Controller battery/cache-policy status (see "Cache safety").
2. TrueNAS version actually reached after the upgrade (needs 25.10.0 or newer).
