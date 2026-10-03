# Moving every volume to TrueNAS iSCSI and removing Rook-Ceph

Goal (owner, 2026-10-03): all PVCs on `truenas-iscsi`, `truenas-iscsi` the default class, Rook-Ceph removed.
Companion to `PLAN.md`. Nothing here has been run against a real workload yet; `pvc-migrate.sh` is tested on throwaway data.

## Size of the job

30 PVCs at the start (21 on Rook, 9 on NFS); 27 after the unused ones were deleted (18 Rook, 9 NFS); after wave 2: 10 Rook, 7 NFS, 10 iSCSI. Provisioned ~1.2 TiB but **only ~58 GiB is real data** (Prometheus 19, ClickHouse 10,
Gitea runner Docker cache 8, the rest 4 GiB or less), and TrueNAS thin-provisions, so capacity is a non-issue (31 TiB pool)
and copies take minutes, not hours.

| Where | PVC | Notes |
|---|---|---|
| Unused (no pod) | `dev/repo-workspace`, `spinnaker/repo-workspace`, `harness/tiemscaledb` (typo duplicate of `timescaledb`) | probably delete, not migrate |
| Plain YAML, Deployments | monitoring: `prometheus-storage`, `clickhouse-storage`, `grafana-pvc`, `clickstack-mongo-pvc`; spinnaker: `minio-pv-claim`, `mysql-pv-spinnaker` (NFS); gitness: `gitness-pv`, `postgresql-gitness`; harness: `timescaledb` | change `storageClassName` in the YAML after migrating |
| Plain YAML, StatefulSets | gitea runner (`docker-data-runner-0`, `runner-data-runner-0`); spinnaker `valkey-data-valkey-0` (NFS) | volumeClaimTemplates are immutable |
| Helm StatefulSets / Deployments | gitea: postgres-ha x3, valkey x3 (NFS), `gitea-shared-storage` (NFS); harness: postgres, mongodb x3, redis-sentinel x3 (NFS), minio | need the Helm values changed and the StatefulSet recreated |

## The method (`pvc-migrate.sh`)

`pvc-migrate.sh <namespace> <pvc>` moves one PVC to `truenas-iscsi` **keeping its name**, so no manifest has to change
beyond the class. It refuses to run while a pod uses the claim. Steps: mark the old PV `Retain`; create `<pvc>-mig` on
iSCSI; `rsync -aHAXx --numeric-ids` in a Job; verify with a dry-run rsync (must report no differences); keep the new
PV, delete the temporary claim, clear the new PV's `claimRef`; delete the old claim (old PV stays, intact); recreate
`<pvc>` bound to the new PV by `volumeName`; set the new PV back to `Delete`.

Tested 2026-10-03 on a 2 Gi Rook volume with 50 MB of random data, three owners, mode 640 and a symlink: checksums, uids,
modes and the symlink all matched, the volume is ext4 on iSCSI, and the old Rook volume stayed as a `Released` rollback.
Bugs found and fixed while testing (YAML escape; `grep -v` under `pipefail`) and while migrating MySQL (the verify
must ignore `lost+found`, which every new ext4 volume has and an NFS source does not).

**Rollback for any volume:** the old PV still holds the data until you delete it. Clear its `claimRef` and create a PVC
with `volumeName: <old-pv>` on the old class.

### Per-workload runbook

Deployment / plain StatefulSet:
1. `kubectl -n <ns> scale <kind>/<name> --replicas=0`; wait for the pods to go.
2. `./pvc-migrate.sh <ns> <pvc>` (repeat for each PVC of that workload).
3. Edit the manifest in git: `storageClassName: truenas-iscsi` (or drop it once iSCSI is the default); a re-apply of
   the old value would hit the immutable-field error.
4. Scale back up; check the app; keep the old PV until you are satisfied.

Helm StatefulSet: scale to 0, migrate each `data-<sts>-<n>` PVC, then delete the StatefulSet with
`--cascade=orphan` and `helm upgrade` with the storage class set in values, so the recreated StatefulSet adopts the
existing PVCs by name. Locate each chart's values in git first (not yet done).

## Waves (each needs the owner's go-ahead; each app is down for the length of its copy)

0. **Prep: done 2026-10-03.** `truenas-iscsi` is the default class (live and in git); `rook-ceph-block` no longer is.
   Owner decision: this is a lab, very little data matters long term, so no ZFS snapshot task, backups or copies.
1. **Unused volumes: done 2026-10-03.** `dev/repo-workspace`, `spinnaker/repo-workspace` and `harness/tiemscaledb` were
   checked (no pod, no workload spec references them, not defined in git) and deleted.
2. **Small standalone services: done 2026-10-03.** grafana, clickstack-mongo, spinnaker minio, mysql (NFS), valkey (NFS),
   gitness x2, harness timescaledb, gitea runner x2, each scaled to 0, migrated, scaled back up and checked (Grafana kept
   its 34 dashboards; Valkey kept its 5,784 keys; MySQL came back clean with all five Spinnaker schemas and the services
   reconnected). The Gitea runner is crash-looping, but because `gitea-postgresql-ha-pgpool` has been in CrashLoopBackOff
   for weeks (it dials that service), not because of the volume. Manifests that named `rook-ceph-block` now name
   `truenas-iscsi` (clickstack, gitea runner, gitness); the live `runner` StatefulSet template still names the old
   class, so applying `gitea/runner.yaml` needs `kubectl delete sts runner -n gitea --cascade=orphan` first.
3. **Observability: done 2026-10-03.** Prometheus (kept 38 h of history, 130k series, all targets up) and ClickHouse
   (row count intact, ingestion caught up within minutes; the gateway's retry queue drained the gap).
4. **Helm StatefulSets: done 2026-10-03.** Gitea (postgres-ha x3, valkey x3, shared storage, runner) and harness (postgres,
   mongodb x3, redis-sentinel x3, minio). Each StatefulSet was recreated (`--cascade=orphan`) with `truenas-iscsi` in its
   volume template; `gitea/values.yaml` and `gitea/gitea.yaml` now name `truenas-iscsi`. Harness is not defined in this
   repo, so its templates were fixed in the cluster only. All 27 PVCs are on `truenas-iscsi`; nothing Bound is on Rook or NFS.
5. **Remove Rook-Ceph** (below).

## Removing Rook-Ceph (point of no return)

Preconditions: no PV left on `rook-ceph-block`; retained old PVs deleted only after each app is verified; the
**RAID controller battery checked** (everything then depends on that cache; see `PLAN.md`); a few days of
soak. Known snag: the Rook operator has been crash-looping for ~23 days (the `CephObjectStoreAccount` CRD it expects is
not installed), so it will not process a normal teardown. Expect to remove the CephCluster/CephBlockPool finalizers by
hand, then delete the operator, CRDs and namespace, `rm -rf /var/lib/rook` on each node, and reclaim the OSD disks in
Proxmox. Also retire `csi-driver-nfs` and the two `nfs-csi-*` classes once the last NFS volume has moved.

## Things found during the migration

- **Ownership that NFS hid.** Gitea's shared storage was owned by uid 3000 but the pod runs as uid 1000; the old NFS export
  mapped every client to one identity, so `chmod` by uid 1000 worked. On ext4 the init container failed with `chmod:
  Operation not permitted` until the volume was `chown -R 1000:1000`. Expect the same class of problem for any app that
  was quietly relying on NFS's permissive mapping.
- **A 29-day-old wedged pod sandbox** (`runc ... mkdir /sys/fs/cgroup/... cannot allocate memory`) was why
  `gitea-postgresql-ha-pgpool` crash-looped for 5,000+ restarts; deleting the pod fixed it, and Gitea's database path
  works again. Not storage related.
- **Script fixes:** verify ignores `lost+found`; the copy-finished check no longer breaks on large logs (`grep -q` under
  `pipefail`).
- Old volumes were left as `Retain`ed PVs for rollback (Rook and two NFS ones); the NFS ones also leave directories on
  TrueNAS under `Main/K8sData`.

## Risks

- TrueNAS becomes the single point of failure for everything (Git hosting, monitoring, Spinnaker DB). A TrueNAS reboot
  stalls all of it; schedule maintenance accordingly. No backups are planned (owner's call for this lab).
- Battery health of the RAID cache is unknown (acknowledged sync writes rely on it).
- Bandwidth: 1 GbE links are the stated limit (a 600 MB/s result in testing suggests more headroom than that); the whole
  data set is ~58 GiB either way.
