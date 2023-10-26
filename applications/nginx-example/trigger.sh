curl -v -XPOST -H "Content-Type: application/json"  http://spinnaker-local:8080/api/v1/webhooks/webhook/shouldIDeployNginx -d '{"parameters":{"Test":"Value2"}}'
