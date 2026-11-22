# Grafana dashboards

Grafana loads every JSON file here through a file provider. Each directory becomes a Grafana folder and `allowUiUpdates = false` keeps the repo as the source of truth, so change the JSON and not the UI.

Vendored dashboards use the fixed data source uids `prometheus` and `loki`. Instance and job variables were replaced with a `host` variable, because every scrape target carries a `host` label and `instance` is `127.0.0.1:<port>` on most hosts.

## Vendored

| File                            | Source                                                                          | Changes                                                                            |
| ------------------------------- | ------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| `Hosts/node-exporter-full.json` | grafana.com 1860, revision 46                                                   | `host` variable replaces `job`, `nodename` and `node`                              |
| `Hosts/smartctl.json`           | grafana.com 22604, revision 4                                                   | `host` variable replaces `node`; joins and grouping use `host`                     |
| `Network/blocky.json`           | grafana.com 13768, revision 8                                                   | `host` variable replaces `job` and `instance`; dropped the blocking-control canvas |
| `Network/nginx.json`            | grafana.com 12708, revision 1                                                   | `host` variable replaces `instance`                                                |
| `Media/qbittorrent.json`        | martabal/qbittorrent-exporter `grafana/dashboard.json` at commit `600e29491cda` | none besides the data source uid                                                   |

## Written for this repo

`Logs/journal.json`, `Monitoring/{prometheus,grafana,loki,gatus}.json`, `Services/{postgresql,forgejo}.json` and `Media/exportarr.json`. Their metric names come from the exporters' source: Gatus `metrics/metrics.go`, exportarr `internal/arr/collector`, postgres_exporter v0.20.1 `collector`, Forgejo `modules/metrics/collector.go`.
