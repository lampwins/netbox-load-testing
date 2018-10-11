# prometheus config file
data "template_file" "prometheus_config" {
  template = "${file("files/prometheus-config.yaml")}"
  depends_on = ["digitalocean_droplet.netbox"]

  vars {
    target_address = "${digitalocean_droplet.netbox.ipv4_address}"
  }
}

# Create a prometheus server
resource "digitalocean_droplet" "prometheus" {
  image    = "ubuntu-16-04-x64"
  name     = "prometheus-1"
  region   = "nyc1"
  size     = "s-2vcpu-2gb"
  ssh_keys = "${var.ssh_key_ids}"
  depends_on = ["digitalocean_droplet.netbox"]

  # run settup part 1
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /opt/prometheus",
      "cd /opt/prometheus",
      "curl -o prometheus.tar.gz -L https://github.com/prometheus/prometheus/releases/download/v2.4.3/prometheus-2.4.3.linux-amd64.tar.gz",
      "tar -zxf prometheus.tar.gz",
      "mv prometheus-*/prometheus .",
      "chmod +x prometheus"
    ]

    connection {
        type     = "ssh"
        user     = "root"
        private_key = "${file(var.ssh_private_key)}"
    }
  }

  provisioner "file" {
    content     = "${data.template_file.prometheus_config.rendered}"
    destination = "/opt/prometheus/config.yaml"

    connection {
        type     = "ssh"
        user     = "root"
        private_key = "${file(var.ssh_private_key)}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "/opt/prometheus/prometheus --web.listen-address ':9090' --web.enable-lifecycle --config.file '/opt/prometheus/config.yaml' &"
    ]

    connection {
        type     = "ssh"
        user     = "root"
        private_key = "${file(var.ssh_private_key)}"
    }
  }

}

output "ipv4_address_prometheus" {
  value = "${digitalocean_droplet.prometheus.ipv4_address}"
}
