variable "openvpn_local_ip_address" {
 default = ""
 description = "Which local IP address should OpenVPN listen on? (optional)"
}

variable "openvpn_port" {
 default = "1194"
 description = "Which TCP/UDP port should OpenVPN listen on?"
}

variable "openvpn_protocol" {
 default = "udp"
 description = "Sets which type to pick: tcp or udp"
}

variable "openvpn_device" {
 default = "tun"
 description = "Either create a routed IP tunnel (tun) or create a routed IP tunnel (tap). Sets which type to pick: tun to tap"
}

variable "openvpn_dev_node" {
 default = ""
 description = "Windows needs the TAP-Win32 adapter name from the Network Connections panel if you have more than one. On XP SP2 or higher, you may need to selectively disable the Windows firewall for the TAP adapter. Non-Windows systems usually don't need this."
}

variable "openvpn_ca_filename" {
 default = "ca.crt"
 description = "SSL/TLS root certificate (ca) filename available to the openvpn process"
}

variable "openvpn_cert_filename" {
 default = "server.crt"
 description = "Certificate (cert) filename available to the openvpn process"
}

variable "openvpn_private_key_filename" {
 default = "server.key"
 description = "Private key (key) filename available to the openvpn process"
}

variable "openvpn_diffie_hellman_filename" {
 default = "dh2048.pem"
 description = "Generate your own with: openssl dhparam -out dh2048.pem 2048"
}

variable "openvpn_network_topology" {
 default = ""
 description = "Should be subnet (addressing via IP) unless Windows clients v2.0.9 and lower have to be supported (then net30, i.e. a /30 per client) Defaults to net30 (not recommended)"
}

variable "openvpn_server_vpn_subnet" {
 default = "10.8.0.0"
 description = "Configure server mode and supply a VPN subne for OpenVPN to draw client addresses from. The server will take 10.8.0.1 for itself, the rest will be made available to clients. Each client will be able to reach the server on 10.8.0.1. Leave blank if you are ethernet bridging. See the man page for more info."
}

variable "openvpn_server_vpn_subnet_netmask" {
 default = "255.255.255.0"
 description = "Used on the same line with openvpn_server_vpn_subnet. Used to configure the netmask in server mode. Leave blank if you are ethernet bridging. See the man page for more info."
}

variable "openvpn_record_pool_persist_filename" {
 default = "ipp.txt"
 description = "Maintain a record of client <-> virtual IP address associations in this file.  If OpenVPN goes down or is restarted, reconnecting clients can be assigned the same virtual IP address from the pool that was previously assigned."
}

variable "openvpn_server_bridge_interface" {
 default = ""
 description = "Configure server mode for ethernet bridging. You must first use your OS's bridging capability to bridge the TAP interface with the ethernet NIC interface.  Then you must manually set the IP/netmask on the bridge interface, here we assume 10.8.0.4/255.255.255.0. Finally we must set aside an IP range in this subnet (start=10.8.0.50 end=10.8.0.100) to allocate to connecting clients. Leave blank unless you are ethernet bridging."
}

variable "openvpn_server_bridge_interface_netmask" {
 default = ""
 description = "Used on the same line as openvpn_server_bridge_interface. Used to configure the netmask in server mode bridge mode. Leave blank unless you are ethernet bridging."
}

variable "openvpn_server_bridge_interface_range" {
 default = ""
 description = "set aside an IP range in this subnet (start=10.8.0.50 end=10.8.0.100) to allocate to connecting clients. Used on the same line as openvpn_server_bridge_interface. Used to configure the netmask in server mode bridge mode. Leave blank unless you are ethernet bridging. Example value (10.8.0.50 10.8.0.100)"
}

variable "openvpn_push_client_routes" {
 default = ""
 description = <<EOF
  Push routes to the client to allow it to reach other private subnets behind the server.
  Remember that these private subnets will also need to know to route the OpenVPN client address pool (10.8.0.0/255.255.255.0) back to the OpenVPN server.

  default = <<CONFIG
  push "route 192.168.10.0 255.255.255.0"
  push "route 192.168.20.0 255.255.255.0"
  CONFIG
 EOF
}

variable "openvpn_client_config_dir" {
 default = ""
 description = "The client-config-dir option points to a directory with files which contain client specific configurations, like IP addresses for example."
}

variable "openvpn_enable_server_mode_for_dchp_proxy" {
 default = "false"
 description = "Configure server mode for ethernet bridging using a DHCP-proxy, where clients talk to the OpenVPN server-side DHCP server to receive their IP address allocation and DNS server addresses.  You must first use your OS's bridging capability to bridge the TAP interface with the ethernet NIC interface. Note: this mode only works on clients (such as Windows), where the client-side TAP adapter is bound to a DHCP client."
}

variable "openvpn_enable_redirect_gateway" {
 default = "false"
 description = "If enabled, this directive will configure all clients to redirect their default network gateway through the VPN, causing all IP traffic such as web browsing and and DNS lookups to go through the VPN (The OpenVPN server machine may need to NAT or bridge the TUN/TAP interface to the internet in order for this to work properly)."
}

variable "openvpn_learn_address_script_path" {
 default = ""
 description = "script to dynamically modify the firewall in response to access from different clients. See man page for more info on learn-address script."
}

variable "openvpn_windows_network_settings" {
 default = ""
 description = <<EOF
  Certain Windows-specific network settings can be pushed to clients, such as DNS
  or WINS server addresses.  CAVEAT:
  http://openvpn.net/faq.html#dhcpcaveats
  The addresses below refer to the public DNS servers provided by opendns.com.
  Example Usage set this below in this variable:

  default = <<CONFIG
  push "dhcp-option DNS 208.67.222.222"
  push "dhcp-option DNS 208.67.220.220"
  CONFIG
 EOF
}

variable "openvpn_allow_client_to_client_viewing" {
 default = "false" 
 description = "Set true to allow different clients to be able to 'see' each other. By default, clients will only see the server. To force clients to only see the server, you will also need to appropriately firewall the server's TUN/TAP interface."
}

variable "openvpn_allow_duplicate_common_name" {
 default = "false"
 description = "Set to true if multiple clients might connect with the same certificate/key files or common names.  This is recommended only for testing purposes.  For production use, each client should have its own certificate/key pair."
}

variable "openvpn_enable_keepalive" {
 default = "true"
 description = "The keepalive directive causes ping-like messages to be sent back and forth over the link so that each side knows when the other side has gone down. Used in conjuction with openvpn_keepalive_ping_seconds and openvpn_keepalive_period_seconds"
}

variable "openvpn_keepalive_ping_seconds" {
 default = "10"
 description = "Ping every 10 seconds, assume that remote peer is down if no ping received during a 120 second time period. Used in conjuction with openvpn_enable_keepalive and openvpn_keepalive_period_seconds"
}

variable "openvpn_keepalive_period_seconds" {
 default = "120"
 description = "Ping every 10 seconds, assume that remote peer is down if no ping received during a 120 second time period. Used in conjuction with openvpn_keepalive_ping_seconds and openvpn_enable_keepalive"
}

variable "openvpn_tls_auth_secret_key" {
 default = "ta.key"
 description = "For extra security beyond that provided by SSL/TLS, create an 'HMAC firewall' to help block DoS attacks and UDP port flooding. Generate with: 'openvpn --genkey --secret ta.key'. The server and each client must have a copy of this key. The second parameter should be '0' on the server and '1' on the clients."
}

variable "openvpn_cipher" {
 default = "AES-256-CBC"
 description = "Select a cryptographic cipher. This config item must be copied to the client config file as well. Note that v2.4 client/server will automatically negotiate AES-256-GCM in TLS mode. See also the ncp-cipher option in the manpage" 
}

variable "openvpn_compression" {
 default = ""
 description = <<EOF
  For v2.4+: Enable compression on the VPN link and push the option to the client.
  Example Usage set this below in this variable:

  default = <<CONFIG
  compress lz4-v2
  push "compress lz4-v2"
  CONFIG
 EOF
}

variable "openvpn_enable_compression_for_older_clients" {
 default = "false"
 description = "For clients version less than v2.4 use comp-lzo. If you enable it here, you must also enable it in the client config file. (example value 'comp-lzo')"
}

variable "openvpn_max_concurrent_clients" {
 default = ""
 description = "The maximum number of concurrently connected clients we want to allow."
}

variable "openvpn_user" { 
 default = ""
 description = "Sets the OpenVPN daemon user. Used to control the privileges. (Best if user is set to 'nobody'. This depends on where openvpn is installed). Leave blank if installed on windows machines."
}

variable "openvpn_group" {
 default = ""
 description = "Sets the OpenVPN daemon group. Used to control the privileges. (Best if user is set to 'nobody'. This depends on where openvpn is installed). Leave blank if installed on windows machines."
}

variable "openvpn_enable_persist_key" {
 default = "true"
 description = "The persist options will try to avoid accessing certain resources on restart that may no longer be accessible because of the privilege downgrade."
}

variable "openvpn_enable_persist_tun" {
 default = "true"
 description = "The persist options will try to avoid accessing certain resources on restart that may no longer be accessible because of the privilege downgrade."
}

variable "openvpn_status_filename" {
 default = "openvpn-status.log"
 description = "Output a short status file showing current connections, truncated and rewritten every minute."
}

variable "openvpn_log_filename" {
 default = ""
 description = "Filename of the openvpn log. By default, log messages will go to the syslog (or on Windows, if running as a service, they will go to  the /Program Files/OpenVPN/log' directory). Set this file to remove default log sending to syslog or windows directory."
}

variable "openvpn_log_enable_append" {
 default = "true"
 description = "By default, log messages will go to the syslog (or on Windows, if running as a service, they will go to  the /Program Files/OpenVPN/log directory). Use log or log-append to override this default. log will truncate the log file on OpenVPN startup while log-append will append to it. Will truncate the log file on OpenVPN startup if set to false. It will keep it not trucated if true."
}

variable "openvpn_log_verbosity" {
 default = "3"
 description = <<EOF
 
 Set the appropriate level of log
 file verbosity.

 0 is silent, except for fatal errors
 4 is reasonable for general usage
 5 and 6 can help to debug connection problems
 9 is extremely verbose
EOF
}

variable "openvpn_slience_repeat_messages" {
 default = ""
 description = "Silence repeating messages. At most 20 sequential messages of the same message category will be output to the log."
}

variable "openvpn_notify_client_on_restart" {
 default = "true"
 description = "Notify the client that when the server restarts so it can automatically reconnect."
}
