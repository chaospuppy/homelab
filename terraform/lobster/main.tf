locals {
  lobster_host_fqdns = var.domain != "" ? [for host in var.lobster_hosts : format("%s.%s", host, var.domain)] : var.lobster_hosts
}

provider "vsphere" {
  user                 = var.vsphere_username
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = var.allow_unverified_ssl
}

data "vsphere_datacenter" "this_lobster" {
  name = var.lobster_datacenter_name
}

data "vsphere_host" "this_lobster" {
  count         = length(local.lobster_host_fqdns)
  name          = local.lobster_host_fqdns[count.index]
  datacenter_id = data.vsphere_datacenter.this_lobster.id
}

data "vsphere_vmfs_disks" "this_lobster" {
  count          = length(data.vsphere_host.this_lobster)
  host_system_id = data.vsphere_host.this_lobster[count.index].id
  rescan         = true
  filter         = var.lobster_vmfs_disk_filter
}

resource "vsphere_compute_cluster" "this_lobster" {
  # Cluster membership
  name            = var.lobster_cluster_name
  datacenter_id   = data.vsphere_datacenter.this_lobster.id
  host_system_ids = data.vsphere_host.this_lobster[*].id

  # DRS settings
  drs_enabled          = var.drs_enabled
  drs_automation_level = var.drs_automation_level
}

resource "vsphere_datastore_cluster" "this_lobster" {
  name          = var.lobster_datastore_cluster_name
  datacenter_id = data.vsphere_datacenter.this_lobster.id
  sdrs_enabled  = var.lobster_datastore_sdrs_enabled
}

resource "vsphere_vmfs_datastore" "this_lobster" {
  count = var.create_datastores ? length(data.vsphere_host.this_lobster) : 0

  name                 = "${var.lobster_hosts[count.index]}-ds"
  host_system_id       = data.vsphere_host.this_lobster[count.index].id
  disks                = data.vsphere_vmfs_disks.this_lobster[count.index].disks
  datastore_cluster_id = vsphere_datastore_cluster.this_lobster.id
}

data "vsphere_datastore" "datastores" {
  count = var.create_datastores ? 0 : length(var.datastores)

  name          = var.datastores[count.index]
  datacenter_id = data.vsphere_datacenter.this_lobster.id
}

# For now, just use the datastore of the first host as the publisher
resource "vsphere_content_library" "lobster_pub" {
  name            = "${var.lobster_content_library_name_prefix}" #-${var.lobster_hosts[0]}"
  description     = var.lobster_content_library_description
  storage_backing = var.create_datastores ? [vsphere_vmfs_datastore.this_lobster[0].id] : length(var.datastores) > 1 ? [data.vsphere_datastore.datastores[1].id] : [data.vsphere_datastore.datastores[0].id]

  publication {
    authentication_method = var.lobster_content_library_auth_method
    username              = var.lobster_content_library_auth_username != null ? var.lobster_content_library_auth_username : ""
    password              = var.lobster_content_library_auth_password != null ? var.lobster_content_library_auth_password : ""
    published             = var.lobster_content_library_pub_enabled
  }
}

resource "vsphere_content_library_item" "content_library_item" {
  count = length(var.content_library_items)

  name        = var.content_library_items[count.index].name
  description = var.content_library_items[count.index].description
  file_url    = var.content_library_items[count.index].file_url 
  type = var.content_library_items[count.index].type
  library_id  = resource.vsphere_content_library.lobster_pub.id
}
