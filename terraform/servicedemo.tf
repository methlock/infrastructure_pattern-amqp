# PROVIDER
provider "digitalocean" {
    token = "${var.do_token}"
}


# SERVICE PROJECT
resource "digitalocean_project" "service-demo" {
  name        = "Service demo"
  description = "Service-demo infrastructure"
  purpose     = "Service or API"
  environment = "Development"
  resources   = [
    "${digitalocean_droplet.service-amqp.urn}",
    "${digitalocean_droplet.service-database.urn}",
    "${digitalocean_droplet.service-api.urn}",
    "${digitalocean_droplet.service-worker-1.urn}",
    "${digitalocean_droplet.service-worker-2.urn}"
  ]
}


# TEMPLATES
data "template_file" "service_ampq_setup" {
  template = "${file("${path.module}/scripts/service_amqp_setup.sh.tpl")}"
}
data "template_file" "service_database_setup" {
  template = "${file("${path.module}/scripts/service_database_setup.sh.tpl")}"
}
data "template_file" "service_server_setup" {
  template = "${file("${path.module}/scripts/service_server_setup.sh.tpl")}"
}
data "template_file" "service_api_setup" {
  template = "${file("${path.module}/scripts/service_api_setup.sh.tpl")}"
  vars {
    DB_IP = "${digitalocean_droplet.service-database.ipv4_address}"
    BROKER_IP = "${digitalocean_droplet.service-amqp.ipv4_address}"
  }
}
data "template_file" "service_worker_setup" {
  template = "${file("${path.module}/scripts/service_worker_setup.sh.tpl")}"
  vars {
    DB_IP     = "${digitalocean_droplet.service-database.ipv4_address}"
    BROKER_IP = "${digitalocean_droplet.service-amqp.ipv4_address}"
  }
}


# RABBITMQ
resource "digitalocean_droplet" "service-amqp" {
  image = "${var.service_amqp_image}"
  name = "service-rabbit"
  region = "${var.service_region}"
  size = "${var.service_amqp_size}"
  private_networking = true
  ssh_keys = ["${var.ssh_fingerprint}"]
  connection {
      user = "root"
      type = "ssh"
      private_key = "${file(var.pvt_key)}"
      timeout = "2m"
  }
  provisioner "remote-exec" {
      inline = ["${data.template_file.service_ampq_setup.rendered}"]
  }
}


# MYSQL DB
resource "digitalocean_droplet" "service-database" {
  image = "${var.service_database_image}"
  name = "service-database"
  region = "${var.service_region}"
  size = "${var.service_database_size}"
  private_networking = true
  ssh_keys = ["${var.ssh_fingerprint}"]
  connection {
      user = "root"
      type = "ssh"
      private_key = "${file(var.pvt_key)}"
      timeout = "2m"
  }
  provisioner "remote-exec" {
      inline = ["${data.template_file.service_database_setup.rendered}"]
  }
}


# SERVICE API
resource "digitalocean_droplet" "service-api" {
  image = "${var.service_api_image}"
  name = "service-api"
  region = "${var.service_region}"
  size = "${var.service_api_size}"
  private_networking = true
  ssh_keys = ["${var.ssh_fingerprint}"]
  connection {
      user = "root"
      type = "ssh"
      private_key = "${file(var.pvt_key)}"
      timeout = "2m"
  }
  provisioner "remote-exec" {
      inline = ["${data.template_file.service_server_setup.rendered}"]
  }
  provisioner "file" {
    source      = "../"
    destination = "/etc/service"
  }
  provisioner "remote-exec" {
      inline = ["${data.template_file.service_api_setup.rendered}"]
  }
}


# SERVICE WORKERS
resource "digitalocean_droplet" "service-worker-1" {
  image = "${var.service_worker_image}"
  name = "service-worker-1"
  region = "${var.service_region}"
  size = "${var.service_worker_size}"
  private_networking = true
  ssh_keys = ["${var.ssh_fingerprint}"]
  connection {
      user = "root"
      type = "ssh"
      private_key = "${file(var.pvt_key)}"
      timeout = "2m"
  }
  provisioner "remote-exec" {
      inline = ["${data.template_file.service_server_setup.rendered}"]
  }
  provisioner "file" {
    source      = "../"
    destination = "/etc/service"
  }
  provisioner "remote-exec" {
      inline = ["${data.template_file.service_worker_setup.rendered}"]
  }
}

resource "digitalocean_droplet" "service-worker-2" {
  image = "${var.service_worker_image}"
  name = "service-worker-2"
  region = "${var.service_region}"
  size = "${var.service_worker_size}"
  private_networking = true
  ssh_keys = ["${var.ssh_fingerprint}"]
  connection {
      user = "root"
      type = "ssh"
      private_key = "${file(var.pvt_key)}"
      timeout = "2m"
  }
  provisioner "remote-exec" {
      inline = ["${data.template_file.service_server_setup.rendered}"]
  }
  provisioner "file" {
    source      = "../"
    destination = "/etc/service"
  }
  provisioner "remote-exec" {
      inline = ["${data.template_file.service_worker_setup.rendered}"]
  }
}
