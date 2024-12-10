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
  description = "Name of the vsphere cluster to use"
}

variable "uds_datastore_cluster_name" {
  type        = string
  default     = "tinker_DSC"
  description = "Name of the vsphere datastore cluster to use"
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

variable "uds_vm_folder" {
  type        = string
  default     = "UDS"
  description = "Name for the folder in which to place the UDS nodes"
}

variable "persistent_admin_username" {
  type = string
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

variable "template_folder" {
  type        = string
  default     = "UDS_Node_Builds"
  description = "The folder where the VM Template used to clone UDS node Virtual Machines from is"
}

variable "rke2_nodes" {
  type = map(object({
    template_name        = string,
    cpus                 = number,
    memory               = number,
    os                   = string,
    network_adapter_type = string,
    use_static_mac       = bool,
    mac_address          = string,
    disk_size            = string,
    thin_provisioned     = bool
    disk_label           = string
    ansible_info = object(
      {
        group     = string
        host_vars = any
      }
    )
  }))
}
