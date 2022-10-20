** This is a local spinnaker deploying to my local microk8s cluster


** Requirements:
1) An authentication source, aka keycloak, dev okta instance, etc.
- https://developer.okta.com/signup/
- https://www.keycloak.org/

2) Microk8s or kubenretes cluster to deploy to.  I use a 3 node microk8s cluster with the following addons enabled:

```
  addons:
    dns                  # CoreDNS
    ha-cluster           # Configure high availability on the current node
    rbac                 # Role-Based Access Control for authorisation
    traefik              # traefik Ingress controller for external access
```
3) Add a hosts file entry (assuming in a local submit...) for your ingress:
```
192.168.19.228 spinnaker-local
```
This should point to the microk8s cluster ingress endpoint 

4) Secrets
* Need a kubeconfig: ```k create secret generic kubeconfig --from-file kubeconfig```
* Need oauth2 client secrets: ```k create secret generic auth-credentails --from-literal clientSecret='REPLACEME'```

5) Connect to it!  
The spinnaker.yaml includes an ingress that exposts it using host named handling.  That's WHY you need a spinnaker-local hosts entry to point to whatever your microk8s ingress point is.  Literally from there?
http://spinnaker-local:8080/
in a browser :) 
