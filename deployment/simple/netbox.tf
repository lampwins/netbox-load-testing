# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = "${var.do_token}"
}

# Create a netbox server
resource "digitalocean_droplet" "netbox" {
  image    = "ubuntu-16-04-x64"
  name     = "netbox-1"
  region   = "nyc3"
  size     = "s-2vcpu-2gb"
  ssh_keys = "${var.ssh_key_ids}"

  # run settup part 1
  provisioner "remote-exec" {
    inline = [
      "echo '\n\nWAITING 30 SECONDS FOR CLOUD-INIT TO LOAD THE UPDATED DIGITALOCEAN APT SOURCES.LIST FILE\n\n'",
      "sleep 30",  # wait for cloud-init to load the updated apt sources.list
      "apt update",
      "apt install -y postgresql libpq-dev python3 python3-dev python3-setuptools build-essential libxml2-dev libxslt1-dev libffi-dev graphviz libpq-dev libssl-dev zlib1g-dev git redis-server nginx supervisor",
      "easy_install3 pip",
      "git clone -b ${var.git_branch} https://github.com/lampwins/netbox.git /opt/netbox",
      "pip3 install -r /opt/netbox/requirements.txt",
      "pip3 install django-rq",
      "pip3 install gunicorn"
    ]

    connection {
        type     = "ssh"
        user     = "root"
        private_key = "${file(var.ssh_private_key)}"
    }
  }

  # install the prometheus node exporter
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /opt/prometheus",
      "cd /opt/prometheus",
      "curl -o node_exporter.tar.gz -L https://github.com/prometheus/node_exporter/releases/download/v0.16.0/node_exporter-0.16.0.linux-amd64.tar.gz",
      "tar -zxf node_exporter.tar.gz",
      "mv node_exporter-*/node_exporter .",
      "chmod +x node_exporter",
      "/opt/prometheus/node_exporter &"
    ]

    connection {
        type     = "ssh"
        user     = "root"
        private_key = "${file(var.ssh_private_key)}"
    }
  }

  # copy pre-built netbox config
  provisioner "file" {
    source      = "files/configuration.py"
    destination = "/opt/netbox/netbox/netbox/configuration.py"

    connection {
        type     = "ssh"
        user     = "root"
        private_key = "${file(var.ssh_private_key)}"
    }
  }

  # copy pre-built gunicorn config
  provisioner "file" {
    source      = "files/gunicorn_config.py"
    destination = "/opt/netbox/gunicorn_config.py"

    connection {
        type     = "ssh"
        user     = "root"
        private_key = "${file(var.ssh_private_key)}"
    }
  }

  # copy pre-built supervisor config
  provisioner "file" {
    source      = "files/netbox.supervisor.conf"
    destination = "/etc/supervisor/conf.d/netbox.conf"

    connection {
        type     = "ssh"
        user     = "root"
        private_key = "${file(var.ssh_private_key)}"
    }
  }

  # copy pre-built nginx config
  provisioner "file" {
    source      = "files/netbox.nginx.conf"
    destination = "/etc/nginx/sites-available/netbox"

    connection {
        type     = "ssh"
        user     = "root"
        private_key = "${file(var.ssh_private_key)}"
    }
  }

  # copy the netbox database install script
  provisioner "file" {
    source      = "files/netbox_install.sql"
    destination = "/opt/netbox/netbox_install.sql"

    connection {
        type     = "ssh"
        user     = "root"
        private_key = "${file(var.ssh_private_key)}"
    }
  }

  # run settup part 2
  provisioner "remote-exec" {
    inline = [
      "su - postgres -c 'psql -f /opt/netbox/netbox_install.sql'",
      "python3 /opt/netbox/netbox/manage.py migrate",
      "echo \"from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser('admin', 'admin@example.com', 'admin')\" | python3 /opt/netbox/netbox/manage.py shell",
      "python3 /opt/netbox/netbox/manage.py collectstatic --no-input",
      "python3 /opt/netbox/netbox/manage.py loaddata initial_data",
      "rm /etc/nginx/sites-enabled/default",
      "ln -s /etc/nginx/sites-available/netbox /etc/nginx/sites-enabled/netbox",
      "service supervisor restart",
      "service nginx restart"
    ]

    connection {
        type     = "ssh"
        user     = "root"
        private_key = "${file(var.ssh_private_key)}"
    }
  }
}

output "ipv4_address_web" {
  value = "${digitalocean_droplet.netbox.ipv4_address}"
}
