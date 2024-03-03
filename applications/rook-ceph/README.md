## Rook storage system for distributed clustered storage

KEY reason for this:  Ceph installation and management allowing 3 node cluster to have DYNAMIC PV storage that's managed.
* no more having to manage/create node affinity rules OR PV's for each PVC
* Storage can move amongst nodes so if something is "burning" on a single node or I'm patching it boom it can run on a different node


Apply cluster.yaml separately LAST.  This will take a WHILE as it basically builds the "pool" of storage for each node

Then... apply storage.yaml to create a storage pool (default is set) so pods can dynamically provision storage!

## Cautions
See: https://github.com/ceph/ceph-csi/issues/1067#issuecomment-1040561067 for microk8s - have to tweak for how microk8s runs in snap file system
