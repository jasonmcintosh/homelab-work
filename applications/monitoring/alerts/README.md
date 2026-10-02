# Alerts

`ilo-rules.json` defines the iLO hardware alerts; `terraform/alerts.tf` turns them into Grafana-managed
alert rules (folder "Hardware", group `ilo-hardware`, evaluated every 5m, `for: 5m`) and routes anything
labelled `hardware=ilo` to Slack `#alerts` via the bot token in `spinnaker/notification-secrets`
(`slack-bot-token`). Everything else keeps going to the default email receiver. The bot only has
`chat:write`, so it must be invited to the channel.

| Alert | Fires when |
|---|---|
| ILODriveUnhealthy | `ilo_storage_disk_healthy` < 1 (per drive) |
| ILODriveFailurePredicted | `ilo_storage_disk_failure_predicted` > 0 |
| ILOPowerSupplyUnhealthy / ILOMemoryUnhealthy / ILOProcessorUnhealthy / ILOFanUnhealthy / ILOTemperatureUnhealthy | the matching `*_healthy` < 1 |
| ILOServerDown | `ilo_power_up` < 1 (server off, or the exporter can't query the iLO, e.g. 401) |
| ILOMetricsMissing | no `ilo_power_up` sample for a host for over 60 minutes |

Each query returns one row per component with the latest value from the last hour (iLO is scraped every
15 minutes). A rule that returns no rows is treated as OK; ILOMetricsMissing covers absent data.

Test a change without applying by evaluating the queries against Grafana's `/api/v1/eval` endpoint
(reduce `last` on query A, then the threshold) - this is how the rules were checked.
