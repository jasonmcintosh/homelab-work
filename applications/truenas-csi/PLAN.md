# Plan: TrueNAS CSI driver (iSCSI + NFS) on the cluster

Status: **planned, nothing deployed.** Blocked on the TrueNAS upgrade to 25.10 (the official driver needs 25.10.0+).

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

## Risks and decisions

- TrueNAS becomes a single point of failure for every database that moves: pods hang if it is down or rebooting.
  (Rook `size: 1` has the same property per node/OSD.) Schedule TrueNAS maintenance accordingly.
- The RAID controller cache must be battery/flash backed for `sync=standard` acknowledgements to be safe.
- ZFS sits on one hardware volume: it detects corruption but cannot self-heal; RAID6 provides redundancy. For
  irreplaceable datasets consider `copies=2`.
- Network speed between the nodes and TrueNAS bounds throughput (NFS sequential writes measured 44 MB/s with a
  484 ms tail, which looks network- or array-limited); iSCSI will share that link.
- IPv4 portals only (driver limitation); fine for this network.
- The driver creates UUID-named datasets/targets; do not edit them by hand.

## Open questions

1. Link speed between the nodes and TrueNAS (1 GbE vs 10 GbE)?
2. Is the RAID controller cache battery/flash backed?
3. One driver for both NFS and iSCSI (replace `csi-driver-nfs`), or keep the NFS driver as is?
