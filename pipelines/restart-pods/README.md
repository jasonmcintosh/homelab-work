Simple demo pipeline to allow a restart of a predefined deployment via a webhook that's parameterized

Can be executed via:
```bash
curl -X POST -v -H "Content-Type: application/json" http://spinnaker.mcintosh.farm/api/v1/webhooks/webhook/restartSomeDeploymentService -d '{"restartCreds":"isSomeSecuredEntry"}'
```
