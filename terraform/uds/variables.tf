variable "vsphere_username" {
  sensitive   = true
  type        = string
  description = "User used to authenticate with vSphere API"
}

variable "vsphere_password" {
  sensitive   = true
  type        = string
  description = "Password used to authenticate with vSphere API"
}

variable "vsphere_server" {
  type        = string
  default     = "vcenter.box"
  description = "FQDN or IP of the vSphere API"
}

variable "allow_unverified_ssl" {
  type        = bool
  default     = true
  description = "Set to false to force SSL verification of vSphere server certificate"
}

variable "domain" {
  type    = string
  default = "box"
}

variable "uds_datacenter_name" {
  type        = string
  default     = "tinker_DC"
  description = "Name of the target datacenter"
}

variable "lobster_datacenter_name" {
  type        = string
  default     = "lobster_DC"
  description = "Name of the target datacenter"
}

variable "uds_cluster_name" {
  type        = string
  default     = "tinker_CC"
  description = "Name of the vsphere cluster to create."
}

variable "uds_datastore_cluster_name" {
  type        = string
  default     = "tinker_DSC"
  description = "Name of the vsphere datastore cluster to use."
}

variable "uds_datastore_name" {
  type        = string
  default     = null
  description = "Name of the vsphere datastore to use."
}

variable "uds_network_name" {
  type        = string
  default     = "VM Network"
  description = "Name of the UDS network"
}

variable "uds_guest_os" {
  type        = string
  default     = "ubuntu64Guest"
  description = "Guest OS type for the UDS Kubernetes node VMs"
}

variable "uds_control_plane_cpus" {
  type        = number
  default     = 4
  description = "Number of CPUs to make available to UDS control plane nodes"
}

variable "uds_control_plane_memory" {
  type        = number
  default     = 12288
  description = "Amount of memory, in MB, to make available to UDS control plane nodes"
}

variable "uds_worker_cpus" {
  type        = number
  default     = 6
  description = "Number of CPUs to make available to UDS worker nodes"
}

variable "uds_worker_memory" {
  type        = number
  default     = 12288
  description = "Amount of memory, in MB, to make available to UDS worker nodes"
}

variable "uds_network_adapter_type" {
  type        = string
  default     = "vmxnet3"
  description = "Type of network adapter to attach to UDS nodes"
}

variable "uds_control_plane_node_count" {
  type        = number
  default     = 1
  description = "Number of control plane nodes to provision"
}

variable "uds_worker_node_count" {
  type        = number
  default     = 2
  description = "Number of control plane nodes to provision"
}

variable "uds_disk_label_prefix" {
  type        = string
  default     = "uds"
  description = "Prefix for disk label attached to control plane disk"
}

variable "uds_control_plane_disk_size" {
  type        = number
  default     = 200
  description = "Size of control plane disk in GB"
}

variable "uds_worker_disk_size" {
  type        = number
  default     = 200
  description = "Size of worker disk in GB"
}

variable "uds_vm_folder" {
  type        = string
  default     = "UDS"
  description = "Name for the folder in which to place the UDS nodes"
}

variable "vm_template_name" {
  type        = string
  default     = "uds_node_ubuntu_rke2"
  description = "The name of the VM Template to use for the RKE2 nodes"
}

variable "uds_disk_thin_provisioned" {
  type        = bool
  default     = false
  description = "Determines if UDS node disks are thin provisioned"
}

variable "persistent_admin_username" {
  type = string
  # sensitive = true
}

variable "persistent_admin_password" {
  type      = string
  sensitive = true
}

variable "debug" {
  type        = bool
  default     = false
  description = "If debug is enabled, then the token generated from Rancher will not be marked sensative, allowing more complete logging."
}
