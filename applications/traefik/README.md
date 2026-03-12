## Traefik 

This is used in my cluster in a few places to do weighted route rules (e.g. my demo app)

Installed/udpated by:

```
helm template --include-crds --values values.yaml --namespace traefik traefik traefik/traefik > traefik.yaml
```
