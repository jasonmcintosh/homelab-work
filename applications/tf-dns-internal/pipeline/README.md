## This pipeline runs a TF apply hourly to update DNS for my internal home network

WARNING:  The features used here ARE PRORPIETARY TO ARMORY.  This is meant as a DEMO as well though I use it for my home lab.

## How it works
* Stores state in k8s 
* Uses cloudflare's free tier to manage my dns - was using google domains but wanted something with a real API
* The idea is to ALSO allow me to generate CERTS for testing locally :) 
* This is setup with a cron trigger to run hourly.  Since it's my home private network I can't trigger via a remote github hook... CURRENTLY :P

## How it works
Loads a secret containing my creds to cloudflare
Updates cloudflare dns records every hour by doing a terraform apply state


## What it looks like in spinnaker
![Screenshot](https://p-qKFvWn.b3.n0.cdn.getcloudapp.com/items/WnuZyw7v/ac1799f4-ac33-4d48-a4d2-2e8ef3afc176.jpg?v=bb9c9d76e210811b67ca014668b24e68)

I could have overriden/set the storage... OR other parameters, but this is super simple... and KISS :P 
