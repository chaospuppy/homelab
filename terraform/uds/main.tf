provider "vsphere" {
  user                 = var.vsphere_username
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = var.allow_unverified_ssl
}

locals {
  rke2_token = var.debug ? random_string.rke2_token[0].result : random_password.rke2_token[0].result
  # Get a list of groups defined in rke2_nodes
  groups = toset([for node in var.rke2_nodes : node.ansible_info.group])
  # Map the groups to the IP addresses of the nodes included in each group
  group_to_ip = {
    for group in local.groups :
    group => [
      for node in keys(var.rke2_nodes) : vsphere_virtual_machine.uds_node[node].default_ip_address
      if var.rke2_nodes[node].ansible_info.group == group
    ]
  }
  # Map node names to the ansible hostvars defined for that host 
  node_to_vars = {
    for node in keys(var.rke2_nodes) : node => var.rke2_nodes[node].ansible_info.host_vars
  }
  unique_templates = toset([for node in var.rke2_nodes : node.template_name])
}

data "vsphere_datacenter" "uds" {
  name = var.uds_datacenter_name
}

data "vsphere_datacenter" "lobster" {
  name = var.lobster_datacenter_name
}

data "vsphere_compute_cluster" "uds" {
  name          = var.uds_cluster_name
  datacenter_id = data.vsphere_datacenter.uds.id
}

data "vsphere_datastore_cluster" "uds" {
  count         = var.uds_datastore_cluster_name == null ? 0 : 1
  name          = var.uds_datastore_cluster_name
  datacenter_id = data.vsphere_datacenter.uds.id
}

data "vsphere_datastore" "datastore" {
  count         = var.uds_datastore_name == null ? 0 : 1
  name          = var.uds_datastore_name
  datacenter_id = data.vsphere_datacenter.uds.id
}

data "vsphere_network" "uds" {
  name          = var.uds_network_name
  datacenter_id = data.vsphere_datacenter.uds.id
}

data "vsphere_virtual_machine" "template" {
  for_each      = local.unique_templates
  name          = each.key
  folder        = var.template_folder
  datacenter_id = data.vsphere_datacenter.lobster.id
}

resource "vsphere_folder" "uds" {
  path          = var.uds_vm_folder
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.uds.id
}

resource "random_string" "rke2_token" {
  count   = var.debug == true ? 1 : 0
  length  = 16
  special = false
}

resource "random_password" "rke2_token" {
  count   = var.debug == false ? 1 : 0
  length  = 16
  special = false
}

resource "vsphere_virtual_machine" "uds_node" {
  for_each             = var.rke2_nodes
  name                 = each.key
  resource_pool_id     = data.vsphere_compute_cluster.uds.resource_pool_id
  datastore_cluster_id = var.uds_datastore_cluster_name == null ? null : data.vsphere_datastore_cluster.uds[0].id
  datastore_id         = var.uds_datastore_name == null ? null : data.vsphere_datastore.datastore[0].id
  folder               = vsphere_folder.uds.path

  num_cpus         = each.value.cpus
  memory           = each.value.memory
  guest_id         = each.value.os
  enable_disk_uuid = true

  wait_for_guest_net_timeout = 10

  network_interface {
    network_id     = data.vsphere_network.uds.id
    adapter_type   = each.value.network_adapter_type
    use_static_mac = each.value.use_static_mac
    mac_address    = each.value.mac_address
  }
  disk {
    label            = each.value.disk_label
    size             = each.value.disk_size
    thin_provisioned = each.value.thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template["${each.value.template_name}"].id
  }

  connection {
    type     = "ssh"
    user     = var.persistent_admin_username
    password = var.persistent_admin_password
    host     = self.default_ip_address
  }
}

resource "local_file" "host_vars" {
  for_each = local.node_to_vars
  filename = "./ansible/host_vars/${vsphere_virtual_machine.uds_node[each.key].default_ip_address}"
  content  = yamlencode(merge(each.value, { "hostname" : replace(each.key, "_", "-") }))
}

resource "terraform_data" "ansible_inventory" {
  triggers_replace = [
    { for key, node in vsphere_virtual_machine.uds_node : key => node.id },
  ]
  provisioner "local-exec" {
    working_dir = "./ansible/"
    command     = "echo \"${templatefile("./files/ansible-inventory.yaml.tftpl.hcl", { groups = local.group_to_ip })}\" > /tmp/ansible-inventory"
  }
}

resource "terraform_data" "ansible" {
  triggers_replace = [
    { for key, node in vsphere_virtual_machine.uds_node : key => node.id },
  ]
  provisioner "local-exec" {
    working_dir = "./ansible/"
    command     = "sleep 20 && ansible-playbook rke2-playbook.yaml -i /tmp/ansible-inventory -v --ssh-extra-args=\"-o Ciphers='aes256-ctr,aes192-ctr,aes128-ctr' -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null\" --extra-vars \"ansible_ssh_timeout=60 ansible_user=${var.persistent_admin_username} ansible_password=${var.persistent_admin_password} rke2_token=${local.rke2_token} \" -b"
  }
  depends_on = [
    local_file.host_vars,
    terraform_data.ansible_inventory
  ]
}
