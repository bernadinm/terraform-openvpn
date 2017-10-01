variable "key_algorithm" {
 default = "RSA"
}

resource "tls_self_signed_cert" "ca_cert" {
  key_algorithm     = "${var.key_algorithm}"
  private_key_pem   = "${tls_private_key.openvpn_key.private_key_pem}"
  is_ca_certificate = "true"

  subject {
    common_name  = "${var.top_level_domain}" 
    organization = "ACME Examples, Inc"
  }

  validity_period_hours = 12

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "ipsec_tunnel"
  ]
}

resource "tls_private_key" "openvpn_key" {
  algorithm = "${var.key_algorithm}"
  rsa_bits  = "2048"
}
