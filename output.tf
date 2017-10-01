output "OpenVPN Server IP Address" {
 value = "${google_compute_instance.vm.network_interface.0.access_config.0.assigned_nat_ip}"
}

output "SSH Name" {
 value = "${var.gce_ssh_user}@${google_compute_instance.vm.network_interface.0.access_config.0.assigned_nat_ip}"
}

output "Managed DNS Name Servers" {
 value = "${google_dns_managed_zone.my_managed_zone.name_servers}"
}

output "Domain Name" {
 value = "vpn.${var.top_level_domain}"
}

output "OpenVPN Root CA Cert" {
 value = "${tls_self_signed_cert.ca_cert.cert_pem}"
}

output "OpenVPN Private Key" {
 value = "${tls_private_key.openvpn_key.private_key_pem}"
}

output "OpenVPN Cert" {
 value = "${tls_private_key.openvpn_key.public_key_pem}"
}
