# home-lab
Applications and setup for my lab (which is close to prod grade IMHO).  Lab is two DL380P Gen 9 servers, running a mix of microk8s cluster (currently 1.31 based) and supporting infrastructure.  I also run a number of home services like storage & home automation.  In the past it was vmware based, but I've moved away from vmware entirely at this point.

This contains numerous docs, installations, supporting installations for applications & services.  This includes harness, spinnaker, homebridge, metallb, etc. I  use an Okta integration environment for auth for most things, though keycloak is an option, I like Okta and recommend them and this lets me test various systems with it.


NOTE:  MANY of the resources in this are done via COMMERCIAL licenses which are NOT open source.  There ARE resources that ARE OSS however.  WHere possible I use RAW manifests vs. helm charts or similar so you can see exactly what's going on under the hood.
