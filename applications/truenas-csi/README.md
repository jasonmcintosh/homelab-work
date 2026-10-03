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

Re-render after changing `values.yaml` (same pattern as `../nfs-provisioner`):

```
helm repo add truenas-csi https://raw.githubusercontent.com/truenas/truenas-csi/master/charts
helm template truenas-csi truenas-csi/truenas-csi --version 1.3.0 -n kube-system -f values.yaml > truenas-csi.yaml
```

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
- Retiring `csi-driver-nfs` (only after the permissions test in `PLAN.md`).
