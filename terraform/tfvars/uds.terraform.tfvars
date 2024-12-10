rke2_nodes = {
  control_tinker_plane_0 = {
    template_name        = "uds_node_ubuntu_rke2"
    cpus                 = 4
    memory               = 12288
    os                   = "ubuntu64Guest"
    network_adapter_type = "vmxnet3"
    use_static_mac       = false
    mac_address          = ""
    disk_size            = "200"
    thin_provisioned     = false
    disk_label           = "uds-uds-control-0"
    ansible_info = {
      group     = "controlplane"
      host_vars = {}
    }
  },
  uds_tinker_worker_0 = {
    template_name        = "uds_node_ubuntu_rke2"
    cpus                 = 6
    memory               = 12288
    os                   = "ubuntu64Guest"
    network_adapter_type = "vmxnet3"
    use_static_mac       = false
    mac_address          = ""
    disk_size            = "200"
    thin_provisioned     = false
    disk_label           = "uds-uds-worker-0"
    ansible_info = {
      group     = "workers"
      host_vars = {}
    }
  }
  uds_tinker_worker_1 = {
    template_name        = "uds_node_ubuntu_rke2"
    cpus                 = 6
    memory               = 12288
    os                   = "ubuntu64Guest"
    network_adapter_type = "vmxnet3"
    use_static_mac       = false
    mac_address          = ""
    disk_size            = "200"
    thin_provisioned     = false
    disk_label           = "uds-uds-worker-1"
    ansible_info = {
      group = "workers"
      host_vars = {
        node_labels = [
          "example=sure"
        ]
      }
    }
  }
}

