# output "vnics" {
#   value = vsphere_vnic.uds
# }

output "hosts" {
  value = local.tinker_host_fqdns
}

output "tinker_vsphere_hosts" {
  value = data.vsphere_host.this_tinker
}

# output "uds_network" {
#   value = vsphere_distributed_virtual_switch.uds
# }

# output "uds_pub_content_library" {
#   value = vsphere_content_library.uds_pub
# }
