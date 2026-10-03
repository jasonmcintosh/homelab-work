# TrueNAS CSI driver

Official driver ([truenas/truenas-csi](https://github.com/truenas/truenas-csi), GPL-3.0, chart 1.3.0) providing
dynamically provisioned iSCSI block volumes (`truenas-iscsi`) and NFS shares (`truenas-nfs`) from TrueNAS.
Both classes are non-default; `rook-ceph-block` stays the default. See `PLAN.md` for the rollout and risks.

## Install

The API key Secret already exists (created by hand, never committed): `kube-system/truneas-api-key`, key `api-key`
(the name is spelled that way on purpose; `values.yaml` references it).

```
kubectl apply -f truenas-csi.yaml
kubectl -n kube-system rollout status deploy/truenas-csi-controller ds/truenas-csi-node
```

Re-render after changing `values.yaml` (values here, rendered manifest committed alongside):

```
helm repo add truenas-csi https://raw.githubusercontent.com/truenas/truenas-csi/master/charts
helm template truenas-csi truenas-csi/truenas-csi --version 1.3.0 -n kube-system -f values.yaml > truenas-csi.yaml
```

## Gotchas (found installing it)

- `truenas.iscsiPortal` must be an IP (`192.168.17.150:3260`), not the hostname; see `PLAN.md` for the evidence. If
  TrueNAS's IP changes, update it in `values.yaml`, re-render, apply, and restart the driver pods.
- NFS subnets belong in the `nfs.networks` StorageClass parameter; `nfs.hosts` is for single hosts. StorageClass
  parameters are immutable, so changing them means deleting and recreating the class (nothing breaks if no PVs use it).

## Smoke test

```
kubectl apply -f - <<'YAML'
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: truenas-smoke, namespace: default}
spec:
  accessModes: [ReadWriteOnce]
  storageClassName: truenas-iscsi
  resources: {requests: {storage: 1Gi}}
YAML
kubectl get pvc truenas-smoke     # Bound; a zvol appears under Main/k8s/iscsi
```

Then mount it from a pod, write as a non-root user, and delete the PVC (`reclaimPolicy: Delete` removes the zvol).
If provisioning fails because the parent datasets (`Main/k8s/iscsi`, `Main/k8s/nfs`) do not exist, create them in
TrueNAS first; the controller log (`kubectl -n kube-system logs deploy/truenas-csi-controller -c truenas-csi`) says
what it was missing. Likewise an iSCSI portal/initiator group may need to exist if the driver does not create one.

## Not done yet

- `VolumeSnapshotClass`/snapshot support: install the external-snapshotter CRDs and snapshot-controller, then set
  `volumeSnapshotClass.enabled: true` and re-render.
- Nothing outstanding. `csi-driver-nfs` and its classes were retired on 2026-10-03 (this driver's `truenas-nfs` class replaces them).
