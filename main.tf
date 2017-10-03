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

   network_interface {
     network = "default"
   }

    service_account {
        scopes = ["https://www.googleapis.com/auth/compute.readonly"]
    }
}
 
resource "null_resource" "openvpn-install" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers {
    current_vm_instance_id = "${google_compute_instance.vm.id}"
  }
  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
    host = "${google_compute_instance.vm.network_interface.0.access_config.0.assigned_nat_ip}"
    user = "${var.gce_ssh_user}"
    private_key = "${file("~/.ssh/id_rsa")}"
  }

  provisioner "file" {
    content =<<SCRIPT
#!/bin/sh
SUBNETWORK=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/subnetwork" | cut -f1 -d"/")
docker pull bernadinm/openssl:1.1.0e
docker pull bernadinm/openvpn:2.4.0
mkdir -p openvpn-data/certs 
cat > openvpn-data/certs/ca.crt <<EOF
${tls_self_signed_cert.ca_cert.cert_pem}
EOF
cat > openvpn-data/certs/server.key <<EOF
${tls_private_key.openvpn_key.private_key_pem}
EOF
cat > openvpn-data/certs/server.crt <<EOF
${tls_private_key.openvpn_key.public_key_pem}
EOF
cat > openvpn-data/server.conf <<EOF
ca openvpn-data/certs/ca.crt
cert openvpn-data/certs/server.crt
key openvpn-data/certs/server.key
dh openvpn-data/certs/dh2048.pem
cipher AES-256-CBC
dev tun
explicit-exit-notify 1
ifconfig-pool-persist ipp.txt
keepalive 10 120
persist-key
persist-tun
port 1194
proto udp
server 10.8.0.0 255.255.255.0
status openvpn-status.log
verb 3
EOF
#docker run -it --entrypoint=/bin/sh -v ~/openvpn-data:/openvpn-data bernadinm/openssl:1.1.0e -c 'openssl dhparam -out openvpn-data/certs/dh2048.pem 2048'
docker run -it --entrypoint=/bin/sh -v ~/openvpn-data:/openvpn-data bernadinm/openvpn:2.4.0 -c 'openvpn --config openvpn-data/server.conf'
SCRIPT
destination = "run.sh"
 }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x run.sh",
      "bash ./run.sh",
    ]
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
