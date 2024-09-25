provider "vsphere" {
  user                 = var.vsphere_username
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = var.allow_unverified_ssl
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

resource "random_password" "rke2_token" {
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

  provisioner "remote-exec" {
    inline = [
      "#!/bin/bash",
      "sleep 4m", # The VMs need enough time to get the correct time.  4 is my favoriate magic number.
      "DISTRO=$( cat /etc/os-release | tr [:upper:] [:lower:] | grep -Poi '(ubuntu|rhel)' | uniq )",
      "if [[ $DISTRO == 'ubuntu' ]]; then lvresize -rl +100%FREE /dev/ubuntu-vg/ubuntu-lv; fi",
      # Add a nameserver to /etc/resolv.conf to prevent CoreDNS CrashLoopBackoff
      "if [[ $DISTRO != 'ubuntu' ]]; then echo 'nameserver 8.8.8.8' > ~/resolv.conf.tmp && sudo cp ~/resolv.conf.tmp /etc/resolv.conf && rm ~/resolv.conf.tmp; fi",
      "sudo hostnamectl set-hostname uds-control-plane-${count.index}", # host_name above didn't take effect for Ubuntu
      count.index == 0 ?
      "sudo /opt/rke2-startup.sh -s $(ip route get $(ip route show 0.0.0.0/0 | grep -oP 'via \\K\\S+') | grep -oP 'src \\K\\S+') -t ${random_password.rke2_token.result}" :
      "sudo /opt/rke2-startup.sh -s ${vsphere_virtual_machine.uds_control_plane[0].default_ip_address} -t ${random_password.rke2_token.result}",
      "sudo cp /etc/rancher/rke2/rke2.yaml ~/",
      "sudo chown ${var.persistent_admin_username}:${var.persistent_admin_username} ~/rke2.yaml"
    ]
  }

  provisioner "local-exec" {
    quiet   = true
    command = count.index == 0 ? "sshpass -p ${var.persistent_admin_password} scp -q -o Ciphers='aes256-ctr,aes192-ctr,aes128-ctr' -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${var.persistent_admin_username}@${self.default_ip_address}:~/rke2.yaml ${path.cwd}/rke2.yaml" : "echo 'rke2.yaml already retrieved, skipping'"
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

  provisioner "remote-exec" {
    inline = [
      "#!/bin/bash",
      "DISTRO=$( cat /etc/os-release | tr [:upper:] [:lower:] | grep -Poi '(ubuntu|rhel)' | uniq )",
      "if [[ $DISTRO == 'ubuntu' ]]; then lvresize -rl +100%FREE /dev/ubuntu-vg/ubuntu-lv; fi",
      "if [[ $DISTRO != 'ubuntu' ]]; then echo 'nameserver 8.8.8.8' > ~/resolv.conf.tmp && sudo cp ~/resolv.conf.tmp /etc/resolv.conf && rm ~/resolv.conf.tmp; fi", # this is gross
      "sleep 4m",                                                                                                                                                   # The VMs need enough time to get the correct time.  4 is my favoriate magic number.
      "sudo hostnamectl set-hostname uds-worker-${count.index}",                                                                                                    # host_name above didn't take effect for Ubuntu
      "sudo /opt/rke2-startup.sh -s ${vsphere_virtual_machine.uds_control_plane[0].default_ip_address} -t ${random_password.rke2_token.result} -a",
    ]
  }
}
