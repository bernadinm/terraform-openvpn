variable "google_project" {
 default = "openvpn-project"
}

variable "google_region" {
 default = "us-west1"
}

variable "top_level_domain" {
 default = "example.com"
 description = "Enter your domain you would like to use like 'example.com'. This will create a 'vpn.example.com'."
}

variable "gce_ssh_pub_key_file" {
 default = "~/.ssh/id_rsa.pub"
 description = "Your ssh public key to log into your the openvpn server"
}

variable "gce_ssh_user" {
 default = "gce_user"
 description = "The ssh username used to log into the server"
}

variable "instance_size" {
 default = "30"
 description = "Free tier max storage"
}
