# Configure the Google Cloud provider
provider "google" {
  credentials = "${file("/Users/mingo/.config/gcloud/application_default_credentials.json")}"
  project     = "${var.google_project}"
  region      = "${var.google_region}"
}

data "google_compute_zones" "available" {}

# Create google network
resource "google_compute_network" "default" {
  name                    = "openvpn-network"
  auto_create_subnetworks = "true"
}

# leverage image
resource "google_compute_image" "bootable-image" {
  name = "my-custom-image"

  raw_disk {
    source = "https://storage.googleapis.com/my-bucket/my-disk-image-tarball.tar.gz"
  }
}

# deploy image
resource "google_compute_instance" "vm" {
  name         = "vm-from-custom-image"
  machine_type = "f1-micro"
  zone         = "data.google_compute_zones.available.names[0]"

  disk {
    image = "${google_compute_image.bootable-image.self_link}"
  }

  network_interface {
    network = "default"
  }
}

