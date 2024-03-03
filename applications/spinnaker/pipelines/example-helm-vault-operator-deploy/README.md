## Example of using hashicorps helm chart repo to dpeloy helm charts to K8s using spinnaker


This is a VERY simplistic example, but does
* Creates the namespace for the vault-secrets-operator
* Bakes the helm manifest INCLUDING CRDs for deployment
* Then deploys it to the target cluster that is set via a simple parameter


Requires helm configuration to be setup in artifacts.  This enables Spinnaker to list the various helm charts. 
