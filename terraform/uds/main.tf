provider "vsphere" {
  user                 = var.vsphere_username
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = var.allow_unverified_ssl
}

locals {
  rke2_token = var.debug ? random_string.rke2_token[0].result : random_password.rke2_token[0].result
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
  count = var.uds_datastore_cluster_name == null ? 0 : 1

  name          = var.uds_datastore_cluster_name
  datacenter_id = data.vsphere_datacenter.uds.id
}

data "vsphere_datastore" "datastore" {
  count = var.uds_datastore_name == null ? 0 : 1

  name          = var.uds_datastore_name
  datacenter_id = data.vsphere_datacenter.uds.id
}

data "vsphere_network" "uds" {
  name          = var.uds_network_name
  datacenter_id = data.vsphere_datacenter.uds.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.vm_template_name
  datacenter_id = data.vsphere_datacenter.lobster.id
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

resource "vsphere_folder" "uds" {
  path          = var.uds_vm_folder
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.uds.id
}

resource "vsphere_virtual_machine" "uds_control_plane" {
  count                = var.uds_control_plane_node_count
  name                 = "uds_control_plane_${count.index}"
  resource_pool_id     = data.vsphere_compute_cluster.uds.resource_pool_id
  datastore_cluster_id = var.uds_datastore_cluster_name == null ? null : data.vsphere_datastore_cluster.uds[0].id
  datastore_id         = var.uds_datastore_name == null ? null : data.vsphere_datastore.datastore[0].id
  folder               = vsphere_folder.uds.path

  num_cpus         = var.uds_control_plane_cpus
  memory           = var.uds_control_plane_memory
  guest_id         = var.uds_guest_os
  enable_disk_uuid = true

  network_interface {
    network_id   = data.vsphere_network.uds.id
    adapter_type = var.uds_network_adapter_type
  }
  disk {
    label            = "${var.uds_disk_label_prefix}-uds-control-${count.index}"
    size             = var.uds_control_plane_disk_size
    thin_provisioned = var.uds_disk_thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    # linked_clone  = "${var.vm_linked_clone}"

    customize {
      timeout = "20"

      linux_options {
        host_name = "uds-control-plane-${count.index}"
        domain    = var.domain
      }
      network_interface {}
    }
  }

  connection {
    type     = "ssh"
    user     = var.persistent_admin_username
    password = var.persistent_admin_password
    host     = self.default_ip_address
  }
}

resource "vsphere_virtual_machine" "uds_worker" {
  count                = var.uds_worker_node_count
  name                 = "uds_worker_${count.index}"
  resource_pool_id     = data.vsphere_compute_cluster.uds.resource_pool_id
  datastore_cluster_id = var.uds_datastore_cluster_name == null ? null : data.vsphere_datastore_cluster.uds[0].id
  datastore_id         = var.uds_datastore_name == null ? null : data.vsphere_datastore.datastore[0].id
  folder               = vsphere_folder.uds.path

  num_cpus         = var.uds_worker_cpus
  memory           = var.uds_worker_memory
  guest_id         = var.uds_guest_os
  enable_disk_uuid = true

  network_interface {
    network_id   = data.vsphere_network.uds.id
    adapter_type = var.uds_network_adapter_type
  }
  disk {
    label            = "${var.uds_disk_label_prefix}-uds-worker-${count.index}"
    size             = var.uds_worker_disk_size
    thin_provisioned = var.uds_disk_thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    # linked_clone  = "${var.vm_linked_clone}"

    customize {
      timeout = "20"

      linux_options {
        host_name = "uds-worker-${count.index}"
        domain    = var.domain
      }
      network_interface {}
    }
  }

  connection {
    type     = "ssh"
    user     = var.persistent_admin_username
    password = var.persistent_admin_password
    host     = self.default_ip_address
  }
}

resource "terraform_data" "ansible" {
  triggers_replace = [
    vsphere_virtual_machine.uds_worker.*.id,
    vsphere_virtual_machine.uds_control_plane.*.id,
  ]
  provisioner "local-exec" {
    working_dir = "./ansible/"
    command     = "echo \"${templatefile("./files/ansible-inventory.yaml.tftpl.hcl", { worker_node_ips = vsphere_virtual_machine.uds_worker.*.default_ip_address, control_plane_ips = vsphere_virtual_machine.uds_control_plane.*.default_ip_address })}\" > /tmp/ansible-inventory && sleep 20 && ansible-playbook rke2-playbook.yaml -i /tmp/ansible-inventory -v --ssh-extra-args=\"-o Ciphers='aes256-ctr,aes192-ctr,aes128-ctr' -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null\" --extra-vars \"ansible_ssh_timeout=60 ansible_user=${var.persistent_admin_username} ansible_password=${var.persistent_admin_password} rke2_token=${local.rke2_token}\" -b"
  }
}
