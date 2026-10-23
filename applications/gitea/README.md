# Gitea

Gitea (chart `gitea` 12.7.0, with `postgresql-ha` 16.3.2 and valkey) on the microk8s tools cluster,
namespace `gitea`. `values.yaml` is the input; `gitea.yaml` is the rendered manifest, with a few edits
by hand (`storageClassName: truenas-iscsi` on the PVCs, the pgpool and PostgreSQL resource limits), so change it in
place or carry those edits over after a fresh `helm template`.

The cluster is reachable only from the internal network.

## TODO before production

- **Database passwords.** The PostgreSQL, repmgr and pgpool passwords are the chart's built-in
  defaults: the same on every render, and committed in `gitea.yaml`. Fine while this is internal
  only. Before production: set real passwords from 1Password (or point the chart at Secrets made by
  hand, kept out of git) and change them in PostgreSQL. Gitea's own keys (secret key, internal
  token, JWT) are generated at install and live in `app.ini` on the data volume, not here.

## Troubleshooting

- **Gitea returns 500s:** check `kubectl -n gitea get pods`. On 2026-10-15 pgpool was in
  CrashLoopBackOff with "container init was OOM-killed" after two days of restarts under the
  chart's 384Mi preset; `kubectl -n gitea rollout restart deployment/gitea-postgresql-ha-pgpool`
  brought it back, and its memory limit is now 768Mi.
  On 2026-10-23 a PostgreSQL replica was OOM-killed at the same preset's 384Mi and the others
  failed their probes under load; PostgreSQL now has 512Mi requested, 1Gi and 1 CPU as limits.
- **A PostgreSQL pod stuck in ContainerCreating** with `failed to connect to iSCSI target ... context
  deadline exceeded`: the TrueNAS CSI driver gives an iSCSI login only 3s. On 2026-10-23 TrueNAS
  took 30s per new login (a pending TrueNAS network change; applying it fixed discovery). A login
  by hand from that node (`iscsiadm -m node -T <iqn> -p 192.168.17.150:3260 --login`, through
  `kubectl debug node/<node> --profile=sysadmin`) let the driver use the session on its next retry.
