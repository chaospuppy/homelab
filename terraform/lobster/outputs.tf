# output "vnics" {
#   value = vsphere_vnic.uds
# }

output "hosts" {
  value = local.lobster_host_fqdns
}

output "lobster_vsphere_hosts" {
  value = data.vsphere_host.this_lobster
}

# output "uds_network" {
#   value = vsphere_distributed_virtual_switch.uds
# }

output "lobster_pub_content_library" {
  value = vsphere_content_library.lobster_pub
}
