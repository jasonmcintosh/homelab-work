## How to deploy spinnaker using spinnaker

* this is a VERY simple pipeline.  It's literally an artifact reference to the pipeline
* It runs hourly as well - which... can be easily changed to say a github trigger instead and have it more automated
* this does NOT do any kind of validation


## NOTE the APP NAME:  spin
This enables all the spinnaker services to show up under the app.  This is directly tied to the naming conventions spinnaker uses and how operator deploys the services.
Spinnaker sets the app name for discovered apps to "<appname>-<cluster>" - so spin-clouddriver-c12345 deploy shows up in the "spin" app, "clouddriver" cluster, "spinnaker" region

IF YOU MATCH the naming conventions... things get easier.  Even in k8s where it uses more of annotations to track apps, matching conventions DOES help


## What does this look like in spinnaker?
![Spinnaker cluster view](https://p-qKFvWn.b3.n0.cdn.getcloudapp.com/items/jkuOdXyN/a9627006-43e4-439a-aac5-df60361479c5.jpg?v=3d2b6c7a225689712cf25a9a92a59a47)
![Pipeline view for spin app](https://p-qKFvWn.b3.n0.cdn.getcloudapp.com/items/OAu298B4/34631f70-8fdd-456d-917b-d3b41fcde628.jpg?v=84bc6b1523ed521792f5645f7e000b8d)
