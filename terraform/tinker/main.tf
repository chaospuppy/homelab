locals {
  tinker_host_fqdns = var.domain != "" ? [for host in var.tinker_hosts : format("%s.%s", host, var.domain)] : var.tinker_hosts
}

provider "vsphere" {
  user                 = var.vsphere_username
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = var.allow_unverified_ssl
}

data "vsphere_datacenter" "this_tinker" {
  name = var.tinker_datacenter_name
}

data "vsphere_host" "this_tinker" {
  count         = length(local.tinker_host_fqdns)
  name          = local.tinker_host_fqdns[count.index]
  datacenter_id = data.vsphere_datacenter.this_tinker.id
}

data "vsphere_vmfs_disks" "this_tinker" {
  count          = length(data.vsphere_host.this_tinker)
  host_system_id = data.vsphere_host.this_tinker[count.index].id
  rescan         = true
  filter         = var.tinker_vmfs_disk_filter
}

resource "vsphere_compute_cluster" "this_tinker" {
  # Cluster membership
  name            = var.tinker_cluster_name
  datacenter_id   = data.vsphere_datacenter.this_tinker.id
  host_system_ids = data.vsphere_host.this_tinker[*].id

  # DRS settings
  drs_enabled          = var.drs_enabled
  drs_automation_level = var.drs_automation_level
}

# resource "vsphere_distributed_virtual_switch" "uds" {
#   name = var.tinker_distributed_vswitch_name

#   datacenter_id   = data.vsphere_datacenter.this.id
#   uplinks         = concat(var.tinker_distributed_vswitch_active_uplinks, var.tinker_distributed_vswitch_standby_uplinks)
#   active_uplinks  = var.tinker_distributed_vswitch_active_uplinks
#   standby_uplinks = var.tinker_distributed_vswitch_standby_uplinks
#   dynamic "host" {
#     for_each = data.vsphere_host.this
#     content {
#       host_system_id = host.value.id
#     }
#   }
# }

# resource "vsphere_distributed_port_group" "uds" {
#   name                            = var.tinker_distributed_port_group_name
#   distributed_virtual_switch_uuid = vsphere_distributed_virtual_switch.uds.id
#   active_uplinks                  = var.tinker_distributed_vswitch_active_uplinks
#   standby_uplinks                 = var.tinker_distributed_vswitch_standby_uplinks
# }

# resource "vsphere_vnic" "uds" {
#   count                   = length(data.vsphere_host.this)
#   host                    = data.vsphere_host.this[count.index].id
#   distributed_switch_port = vsphere_distributed_virtual_switch.uds.id
#   distributed_port_group  = vsphere_distributed_port_group.uds.key
#   ipv4 {
#     dhcp = var.tinker_network_dhcp_enabled
#     # Skip the first three IPs in block in case they need to be assigned to gateways, DHCP servers, etc.
#     ip      = cidrhost(var.tinker_network_cidr, count.index + 3)
#     gw      = var.tinker_network_gateway_ip
#     netmask = cidrnetmask(var.tinker_network_cidr)
#   }
# }

resource "vsphere_datastore_cluster" "this_tinker" {
  name          = var.tinker_datastore_cluster_name
  datacenter_id = data.vsphere_datacenter.this_tinker.id
  sdrs_enabled  = var.tinker_datastore_sdrs_enabled
}

resource "vsphere_vmfs_datastore" "this_tinker" {
  count = var.create_datastores ? length(data.vsphere_host.this_tinker) : 0

  name                 = "${var.tinker_hosts[count.index]}-ds"
  host_system_id       = data.vsphere_host.this_tinker[count.index].id
  disks                = data.vsphere_vmfs_disks.this_tinker[count.index].disks
  datastore_cluster_id = vsphere_datastore_cluster.this_tinker.id
}

data "vsphere_datastore" "datastores" {
  count = var.create_datastores ? 0 : length(var.datastores)

  name          = var.datastores[count.index]
  datacenter_id = data.vsphere_datacenter.this_tinker.id
}

data "terraform_remote_state" "lobster" {
  backend = "local"

  config = {
    path = "../lobster/terraform.tfstate"
  }
}

resource "vsphere_content_library" "tinker_sub" {
  count = var.create_datastores ? length(var.tinker_hosts) : length(var.datastores)

  # Increment indexes here by 1 to skip the first host, which is currently always hosting the publishing datastore
  name            = "${var.tinker_content_library_name_prefix}-${var.tinker_hosts[count.index]}"
  description     = var.tinker_content_library_description
  storage_backing = var.create_datastores ? [vsphere_vmfs_datastore.this_tinker[count.index].id] : [data.vsphere_datastore.datastores[count.index].id]

  subscription {
    subscription_url      = data.terraform_remote_state.lobster.outputs.lobster_pub_content_library.publication[0].publish_url
    authentication_method = var.tinker_content_library_auth_method
    username              = var.tinker_content_library_auth_username != null ? var.tinker_content_library_auth_username : ""
    password              = var.tinker_content_library_auth_password != null ? var.tinker_content_library_auth_password : ""
    automatic_sync        = var.tinker_content_library_sub_auto_sync
    on_demand             = var.tinker_content_library_sub_on_demand
  }
}
