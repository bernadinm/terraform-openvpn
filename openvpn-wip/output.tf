output "server_conf" {
 value = "${data.template_file.server_conf.rendered}"
}
