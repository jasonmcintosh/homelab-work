#!/usr/bin/env bash
# Move one PVC to another StorageClass while keeping its name, so no manifest or Helm value that references the
# claim has to change.
#
#   pvc-migrate.sh <namespace> <pvc> [new-storageclass]      (default new class: truenas-iscsi)
#
# How it works (one data copy, old data kept as a rollback):
#   1. old PV -> reclaimPolicy Retain, so deleting the old PVC can never delete the data
#   2. create <pvc>-mig on the new class, rsync old -> new in a Job, then verify with a dry-run rsync
#   3. new PV -> Retain, delete <pvc>-mig, clear the new PV's claimRef
#   4. delete the old PVC (old PV is Released but intact), create <pvc> bound to the new PV by volumeName
#   5. new PV -> reclaimPolicy Delete again (the normal behavior of the class)
#
# The workload that uses the PVC MUST be stopped first (scale to 0); the script refuses to run otherwise.
# Rollback: the old PV still holds the data. Clear its claimRef and create a PVC with volumeName: <old-pv>.
set -euo pipefail

NS=${1:?usage: $0 <namespace> <pvc> [new-storageclass]}
PVC=${2:?usage: $0 <namespace> <pvc> [new-storageclass]}
NEWSC=${3:-truenas-iscsi}
TMP="${PVC}-mig"
JOB="migrate-${PVC}"
k() { kubectl "$@"; }
say() { printf '\n== %s\n' "$*"; }

say "preflight"
phase=$(k -n "$NS" get pvc "$PVC" -o jsonpath='{.status.phase}')
[ "$phase" = Bound ] || { echo "PVC $NS/$PVC is $phase, not Bound"; exit 1; }
OLDPV=$(k -n "$NS" get pvc "$PVC" -o jsonpath='{.spec.volumeName}')
OLDSC=$(k -n "$NS" get pvc "$PVC" -o jsonpath='{.spec.storageClassName}')
SIZE=$(k -n "$NS" get pvc "$PVC" -o jsonpath='{.spec.resources.requests.storage}')
MODES=$(k -n "$NS" get pvc "$PVC" -o jsonpath='{.spec.accessModes[0]}')
[ "$OLDSC" != "$NEWSC" ] || { echo "already on $NEWSC"; exit 0; }
k get sc "$NEWSC" >/dev/null
users=$(k -n "$NS" get pods -o json | python3 -c "
import json,sys
n='$PVC'
print(' '.join(p['metadata']['name'] for p in json.load(sys.stdin)['items']
  if p['status'].get('phase') not in ('Succeeded','Failed')
  and any(v.get('persistentVolumeClaim',{}).get('claimName')==n for v in p['spec'].get('volumes',[]))))")
[ -z "$users" ] || { echo "refusing: still mounted by pod(s): $users (scale the workload to 0 first)"; exit 1; }
echo "$NS/$PVC  $OLDSC -> $NEWSC  size=$SIZE mode=$MODES  old PV=$OLDPV"

say "1. old PV -> Retain"
k patch pv "$OLDPV" -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}' >/dev/null

say "2. create $TMP on $NEWSC and copy"
k -n "$NS" apply -f - >/dev/null <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: $TMP, namespace: $NS}
spec:
  accessModes: [$MODES]
  storageClassName: $NEWSC
  resources: {requests: {storage: $SIZE}}
EOF
k -n "$NS" wait --for=jsonpath='{.status.phase}'=Bound "pvc/$TMP" --timeout=180s
NEWPV=$(k -n "$NS" get pvc "$TMP" -o jsonpath='{.spec.volumeName}')

k -n "$NS" delete job "$JOB" --ignore-not-found >/dev/null
k -n "$NS" apply -f - >/dev/null <<EOF
apiVersion: batch/v1
kind: Job
metadata: {name: $JOB, namespace: $NS}
spec:
  backoffLimit: 0
  ttlSecondsAfterFinished: 600
  template:
    spec:
      restartPolicy: Never
      containers:
      - name: copy
        image: alpine:3.20
        command: ["sh","-c","apk add --no-cache rsync >/dev/null && rsync -aHAXx --numeric-ids --info=stats1 /src/ /dst/ && echo COPY_DONE && sync && echo '--- verify (dry run; no lines below means identical)' && rsync -aHAXxn --numeric-ids --itemize-changes --delete /src/ /dst/ | grep -v -e '^[.]d' -e 'lost[+]found' ; echo VERIFY_DONE"]
        volumeMounts: [{name: src, mountPath: /src, readOnly: true}, {name: dst, mountPath: /dst}]
      volumes:
      - name: src
        persistentVolumeClaim: {claimName: $PVC, readOnly: true}
      - name: dst
        persistentVolumeClaim: {claimName: $TMP}
EOF
k -n "$NS" wait --for=condition=complete "job/$JOB" --timeout=3600s
k -n "$NS" logs "job/$JOB" | tail -25
k -n "$NS" logs "job/$JOB" | grep -q COPY_DONE || { echo "copy did not finish"; exit 1; }
# grep -v exits 1 when it filters every line (the good case), so guard it against set -e/pipefail
leftover=$(k -n "$NS" logs "job/$JOB" | sed -n '/--- verify/,/VERIFY_DONE/p' | { grep -v -- '--- verify\|VERIFY_DONE' || true; } | wc -l | tr -d ' ')
[ "$leftover" = 0 ] || { echo "verify found $leftover differing entries; stopping (old volume untouched, $TMP kept)"; exit 1; }

say "3. detach new PV from $TMP"
k patch pv "$NEWPV" -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}' >/dev/null
k -n "$NS" delete job "$JOB" >/dev/null
k -n "$NS" delete pvc "$TMP" --wait=true >/dev/null
k wait --for=jsonpath='{.status.phase}'=Released "pv/$NEWPV" --timeout=120s
k patch pv "$NEWPV" --type json -p '[{"op":"remove","path":"/spec/claimRef"}]' >/dev/null

say "4. swap: delete old PVC (data kept on $OLDPV), recreate $PVC on the new volume"
k -n "$NS" delete pvc "$PVC" --wait=true >/dev/null
k -n "$NS" apply -f - >/dev/null <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: $PVC, namespace: $NS}
spec:
  accessModes: [$MODES]
  storageClassName: $NEWSC
  volumeName: $NEWPV
  resources: {requests: {storage: $SIZE}}
EOF
k -n "$NS" wait --for=jsonpath='{.status.phase}'=Bound "pvc/$PVC" --timeout=120s

say "5. new PV -> Delete (class default)"
k patch pv "$NEWPV" -p '{"spec":{"persistentVolumeReclaimPolicy":"Delete"}}' >/dev/null

say "done"
echo "$NS/$PVC is now on $NEWSC (PV $NEWPV)."
echo "Old data is retained as PV $OLDPV ($OLDSC). After you have verified the application:"
echo "  kubectl delete pv $OLDPV     # and, for Rook, the RBD image is removed when the cluster is removed"
