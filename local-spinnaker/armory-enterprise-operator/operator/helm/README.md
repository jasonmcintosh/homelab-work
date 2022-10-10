# Armory Spinnaker Operator on Kubernetes Helm Chart

## Prerequisites

* Kubernetes 1.14+

## Chart Details

This chart does the following:

* Deploy Armory Operator
* Deploy Armory Spinnaker (Optional)

## Requirements

- A running Kubernetes cluster
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) installed and configured to use the cluster
- [Helm](https://helm.sh/) installed and configured to use the cluster

## Install Armory Operator

### Add Armory Helm Repository

Add the Armory charts repo to the Helm client:

```sh
$ helm repo add armory https://armory.jfrog.io/artifactory/charts/
$ helm repo update
```

To install the Armory Operator Chart into your Kubernetes cluster:

```sh
$ helm install armory-spinnaker-operator --namespace spinnaker-operator --wait armory/armory-spinnaker-operator
```

> **Note**: Use the --wait flag for initial creation because the spinnaker creation takes longer than the default 300 seconds

To upgrade the Armory Operator Chart in your Kubernetes cluster:

```sh
$ helm upgrade armory-spinnaker-operator --namespace spinnaker-operator armory/armory-spinnaker-operator
```

To uninstall the release deployment:

```sh
$ helm delete armory-spinnaker-operator --namespace spinnaker-operator
```

### Add Spinnaker Service

The Armory Operator chart provides the ability to deploy a Spinnaker instance using the CRD *SpinnakerService*. View the [Spinnaker Operator Reference](https://docs.armory.io/operator_reference/operator-config/) for configuration details.

Once you have your Spinnaker Service configured, upgrade your Helm chart as follows:

```sh
$ helm upgrade armory-spinnaker-operator --namespace spinnaker-operator --wait \
        --set spinnakerService.enabled=true \       
        -f spinnakerService.yaml \
        armory/armory-spinnaker-operator
```

## Configuration

The following table lists the configurable parameters of the Armory Operator chart and their default values.

### Armory Operator
|         Parameter            |                    Description                   |           Default                  |
|------------------------------|--------------------------------------------------|------------------------------------|
| `spinnakerOperator.rbac.create` | Create RBAC resources	                            | `true` |
| `spinnakerOperator.imagePullSecrets` | Reference to one or more secrets to be used when pulling images | `[]` |
| `spinnakerOperator.enabled` | Create Spinnaker Operator | `true` |
| `spinnakerOperator.serviceAccount.create` | If true armory operator will create Service Account | `true` |
| `spinnakerOperator.serviceAccount.name` | Operator serviceAccount name | `spinnaker-operator` |
| `spinnakerOperator.customConfiguration.enabled` | Creates ConfigMap with Custom halyard configuration https://docs.armory.io/spinnaker/operator/#custom-halyard-configuration | `false` |
| `spinnakerOperator.customConfiguration.name` | Name of ConfigMap with Custom halyard configuration | `halyard-custom-config` |
| `spinnakerOperator.customConfiguration.data` | Content of ConfigMap with Custom halyard configuration | `` |
| `spinnakerOperator.operator.image.repository` | Repository for armory operator image | `index.docker.io/armory/armory-operator` |
| `spinnakerOperator.operator.image.tag` | Tag for armory operator image | `dev` |
| `spinnakerOperator.operator.image.pullPolicy` | Pull policy for armory operator image | `IfNotPresent` |
| `spinnakerOperator.operator.resources` | Resource limits for armory operator | `{}` |
| `spinnakerOperator.operator.volumeMounts`| Volume mounts for the armory operator service | `[]` |
| `spinnakerOperator.halyard.image.repository` | Repository for halyard operator image | `index.docker.io/armory/halyard-armory` |
| `spinnakerOperator.halyard.image.tag` | Tag for halyard operator image | `operator-0.4.x` |
| `spinnakerOperator.halyard.image.pullPolicy` | Pull policy for armory operator image | `IfNotPresent` |
| `spinnakerOperator.halyard.resources` | Resource limits for halyard operator service | `{}` |
| `spinnakerOperator.halyard.volumeMounts`| Volume mounts for the halyard service | `[]` |
| `spinnakerOperator.podLabels` | Labels to add to the operator pod | `{}` |
| `spinnakerOperator.podAnnotations` | Annotations to add to the operator pod | `{}` |
| `spinnakerOperator.nodeSelector` | Armory operator node selector https://kubernetes.io/docs/user-guide/node-selection/ | `{}` |
| `spinnakerOperator.tolerations` | Tolerations for use with node taints https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ | `[]` |
| `spinnakerOperator.affinity` | Assign custom affinity rules to the armory operator https://kubernetes.io/docs/concepts/configuration/assign-pod-node/ | `{}` |
| `spinnakerOperator.securityContext` | SecurityContext for armory operator | `{}` |
| `spinnakerOperator.volumes`| Volumes for the armory operator service | `[]` |

### Armory Spinnaker Service
|         Parameter            |                    Description                   |           Default                  |
|------------------------------|--------------------------------------------------|------------------------------------|
| `spinnakerService.enabled` | Create Spinnaker Service | `false` |
| `spinnakerService.metadata` | Standard object’s metadata. https://github.com/kubernetes/community/blob/master/contributors/devel/sig-architecture/api-conventions.md#metadata | `` |
| `spinnakerService.spinnakerConfig` | This section is how to specify configuration spinnaker https://docs.armory.io/operator_reference/operator-config/#specspinnakerconfig| `` |
| `spinnakerService.expose` | This section defines how Spinnaker should be publicly exposed https://docs.armory.io/operator_reference/operator-config/#specexpose | `` |
| `spinnakerService.validation` | This section defines configuration for Operator validation https://docs.armory.io/operator_reference/operator-config/#specvalidation | `` |
| `spinnakerService.kustomize` | Patching of generated service or deployment by Spinnaker service | `` |

Specify each parameter using the `--set key=value` argument to `helm install`.

Alternatively, provide a YAML file that specifies the values for the parameters while installing the chart. For example,

```console
$ helm install armory-spinnaker-operator --namespace "spinnaker-operator" \
     -f values.yaml --wait armory/armory-spinnaker-operator
```

> **Tip**: You can use the default [values.yaml](values.yaml)
