# home-lab
Generic tools/scripts/docs around my home lab.  Lab is an older DL380P Gen 9 running Xen & a multinode microk8s cluster (currently 1.30 based).  In the past it was vmware based, but... since I didn't managet to buy a license before the broadcom mess at 500, and the price for a purchase now is several thousand, I went OSS.  

This contains numerous docs, installations, supporting installations for applications & services.  This includes harness, spinnaker, homebridge, metallb, etc. I  use a dev okta instance in several places (though keycloak is an option, I like Okta and recommend them and this lets me test various systems with it).


NOTE:  MANY of the resources in this are done via COMMERCIAL licenses which are NOT open source.  There ARE resources that ARE OSS however.  WHere possible I use RAW manifests vs. helm charts or similar so you can see exactly what's going on under the hood.
