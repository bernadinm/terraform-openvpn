# Configure the Google Cloud provider
provider "google" {
  credentials = "${file("myGoogleServiceAccountKey.json")}"
  project     = "${var.google_project}"
  region      = "${var.google_region}"
}

data "google_compute_zones" "available" {}
 
 # Create google network
 resource "google_compute_network" "default" {
   name                    = "openvpn-network"
    auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "dmz" {
    name          = "dmz"
    ip_cidr_range = "192.168.1.0/24"
    network       = "${google_compute_network.default.self_link}"
    region        = "${var.google_region}"
}

resource "google_compute_subnetwork" "internal" {
    name          = "internal"
    ip_cidr_range = "10.0.1.0/24"
    network       = "${google_compute_network.default.self_link}"
    region        = "${var.google_region}"
}
 
resource "google_compute_firewall" "web" {
    name = "web"
    network = "${google_compute_network.default.name}"
    allow {
        protocol = "tcp"
        ports = ["80"]
    }
}

resource "google_compute_firewall" "ssh" {
    name = "ssh"
    network = "${google_compute_network.default.name}"
    allow {
        protocol = "tcp"
        ports = ["22"]
    }
}

 # deploy image
 resource "google_compute_instance" "vm" {
   name         = "openvpn"
   machine_type = "f1-micro"
   zone         = "${data.google_compute_zones.available.names[1]}"
 
  tags = ["vpn"]

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
      size  = "${var.instance_size}"
    }
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.dmz.name}"
    access_config {
        // IP
    }
  } 

  metadata {
    sshKeys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
  }

  metadata_startup_script = "echo 'hello world' | tee -a ~/file"

   network_interface {
     network = "default"
   }
 }
 

resource "google_dns_managed_zone" "my_managed_zone" {
  name        = "managed-zone"
  dns_name    = "${var.top_level_domain}."
  description = "Production DNS zone"
}

resource "google_dns_record_set" "www" {
    name = "vpn.${var.top_level_domain}."
    type = "A"
    ttl = 300
    managed_zone = "${google_dns_managed_zone.my_managed_zone.name}"
    rrdatas = ["${google_compute_instance.vm.network_interface.0.access_config.0.assigned_nat_ip}"]
}
