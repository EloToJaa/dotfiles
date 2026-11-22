# Grafana dashboards

Grafana loads every JSON file here through a file provider. Each directory becomes a Grafana folder and `allowUiUpdates = false` keeps the repo as the source of truth, so change the JSON and not the UI.

Dashboards use the fixed data source uids `prometheus`, `loki` and `tempo`. Instance and job variables were replaced with a `host` variable, because every scrape target carries a `host` label and `instance` is `127.0.0.1:<port>` on most hosts.

## Vendored

| File                            | Source                                                                          | Changes                                                                            |
| ------------------------------- | ------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| `Hosts/node-exporter-full.json` | grafana.com 1860, revision 46                                                   | `host` variable replaces `job`, `nodename` and `node`                              |
| `Hosts/smartctl.json`           | grafana.com 22604, revision 4                                                   | `host` variable replaces `node`; joins and grouping use `host`                     |
| `Network/blocky.json`           | grafana.com 13768, revision 8                                                   | `host` variable replaces `job` and `instance`; dropped the blocking-control canvas |
| `Network/nginx.json`            | grafana.com 12708, revision 1                                                   | `host` variable replaces `instance`                                                |
| `Media/qbittorrent.json`        | martabal/qbittorrent-exporter `grafana/dashboard.json` at commit `600e29491cda` | none besides the data source uid                                                   |

## Written for this repo

`Logs/journal.json`, `Hosts/systemd.json`, `Monitoring/{prometheus,grafana,loki,gatus,alloy,tempo}.json`, `Services/{postgresql,forgejo,red}.json` and `Media/exportarr.json`. Their metric names come from the exporters' source: Gatus `metrics/metrics.go`, Alloy's own `/metrics` endpoint, exportarr `internal/arr/collector`, postgres_exporter v0.20.1 `collector`, Forgejo `modules/metrics/collector.go`.

`Monitoring/tempo.json` uses the names Tempo exposes on `/metrics`. Tempo 3 replaced the ingester and compactor with the live store, block builder, backend scheduler and backend worker, so there are no `tempo_ingester_*` or `tempo_compactor_*` series.

`Hosts/systemd.json` reads the systemd exporter (`systemd_unit_*`, `systemd_timer_*`, `systemd_socket_*`) and the node collector (`node_systemd_units`, `node_systemd_system_running`). The exporter has no restart counter, so restarts are `changes()` of `systemd_unit_start_time_seconds`.

`Services/red.json` is built from the Tempo span metrics (`traces_spanmetrics_*`) and service graph metrics (`traces_service_graph_*`). These carry a `service` label and a `host` label that is the Tempo host, so it has a `service` variable and no `host` variable. The service graph panel and the trace tables query the `tempo` data source.
