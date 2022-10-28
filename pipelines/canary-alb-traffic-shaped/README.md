## Canary analysis using ALB to traffic to a baseline & canary target 10% each

Please note this is a DEMO.  You'd want to change SEVERAL things including:
* Account names - they're using a mock account for the purposes of sharing ;)
* Trigger - I randomly demo'd using a docker trigger, as in theory, that'd be a GREAT way to do this
* Manifest location.  These are CURRENTLY embedded.  NORMALLY I'd store my deployment manifests with my code, so that parameters/arguments/etc. changing would work with my app :) 
* Canary analysis references an analysis that really desn't exist.  Canary config is a wholeeeee different topic.  The canary stage itself is just there as a place holder at the moment vs. working

IT ALSO depends upon the ALB controller, as each LB type really takes some "tweaking".  E.g. ALB's handle differently than other LB types.  

SO this is really more to show HOW a canary can work, depending upon desire/use case vs. a WORKING canary.  BUT it shows the flexibility/control you have over pipelines and how they can operate.
