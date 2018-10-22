provider "grafana" {
  url  = "http://${digitalocean_droplet.prometheus.ipv4_address}:3000/"
  auth = "admin:admin"
}

resource "grafana_data_source" "prometheus" {
  depends_on = ["digitalocean_droplet.prometheus"]
  type          = "prometheus"
  name          = "Prometheus"
  url           = "http://${digitalocean_droplet.prometheus.ipv4_address}:9090/"
  is_default    = true
}

resource "grafana_dashboard" "metrics" {
  depends_on = ["grafana_data_source.prometheus"]
  config_json = "${file("files/grafana_node_exporter_dashboard.json")}"
}

output "grafana_url" {
  value = "http://${digitalocean_droplet.prometheus.ipv4_address}:3000/"
}
