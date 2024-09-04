variable "domain" {
  type    = string
  default = "box"
}

variable "lobster_hosts" {
  type = list(string)
  default = [
    "esxi1",
    "esxi2",
    "esxi3"
  ]
  description = "List of ESXI hosts that will be used for lobster stuff"
}

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

variable "lobster_datacenter_name" {
  type        = string
  default     = "lobster_DC"
  description = "Name of the target datacenter"
}

variable "lobster_cluster_name" {
  type        = string
  default     = "lobster_CC"
  description = "Name of the vsphere cluster to create."
}

variable "lobster_vmfs_disk_filter" {
  type        = string
  default     = ""
  description = "Regex filter used to identify disks used for UDS vsphere storage cluster"
}

variable "lobster_datastore_cluster_name" {
  type        = string
  default     = "lobster_DSC"
  description = "Name of the vsphere datastore to create."
}

variable "create_datastores" {
  type        = bool
  default     = true
  description = "Whether to create or reuse datastores."
}

variable "datastores" {
  type        = list(string)
  default     = null
  description = "List of datastore names to reuse.  create_datastores must be false."
}

variable "lobster_datastore_sdrs_enabled" {
  type        = bool
  default     = true
  description = "Set to true to enable SDRS on the UDS datastore cluster"
}

variable "drs_automation_level" {
  type        = string
  default     = "fullyAutomated"
  description = "Set the automation level for DRS if enabled"
}

variable "drs_enabled" {
  type        = bool
  default     = true
  description = "Set to false to disable DRS managment of new vsphere cluster."
}

variable "lobster_distributed_vswitch_name" {
  type        = string
  default     = "uds-vswitch"
  description = "Name for the created UDS vswitch"
}

variable "lobster_distributed_port_group_name" {
  type        = string
  default     = "uds-pg"
  description = "Name for the created UDS vswitch"
}

variable "lobster_distributed_vswitch_active_uplinks" {
  type        = list(string)
  default     = ["uplink1"]
  description = "List of active uplinks to assign for the UDS distributed vswitch"
}

variable "lobster_distributed_vswitch_standby_uplinks" {
  type        = list(string)
  default     = []
  description = "List of standby uplinks to assign to the UDS distributed vswitch"
}

variable "lobster_network_cidr" {
  type        = string
  default     = "192.168.20.0/23"
  description = "CIDR of the ESXi host network.  Used to calculate a new ipv4 addresses for the UDS VM network"
}

variable "lobster_network_dhcp_enabled" {
  type        = bool
  default     = false
  description = "Set to true to allow UDS VMs to be assigned an address from previously configured DHCP"
}

variable "lobster_network_gateway_ip" {
  type        = string
  default     = "0.0.0.0"
  description = "IP Address for UDS VM Network Gateway"
}

variable "lobster_content_library_name_prefix" {
  type        = string
  default     = "lobster_CL"
  description = "Name for Content library used to store VM media such as ISOs and OVFs"
}

variable "lobster_content_library_description" {
  type        = string
  default     = "Content library used to store VM media such as ISOs and OVFs"
  description = "Description for Content library used to store VM media such as ISOs and OVFs"
}

variable "lobster_content_library_auth_method" {
  type        = string
  default     = "NONE"
  description = "The authentication method used by subscriber content libraries to authenticate with the publisher"
}

variable "lobster_content_library_auth_username" {
  type        = string
  default     = null
  description = "Username used for auth with publication content library"
}

variable "lobster_content_library_auth_password" {
  type        = string
  default     = null
  description = "Password used for auth with publication content library"
}

variable "lobster_content_library_pub_enabled" {
  type        = bool
  default     = true
  description = "Determines if the publish content library can be subscribed to, and consequently if subscription content libraries are created"
}

variable "lobster_content_library_sub_auto_sync" {
  type        = bool
  default     = true
  description = "Determines if the publish content library should be automatically synced to subscribed content libraries"
}

variable "lobster_content_library_sub_on_demand" {
  type        = bool
  default     = false
  description = "Determines if the publish content library should be synced to subscribed content libraries on-demand"
}

variable "content_library_items" {
  type = list(object({
    name = string,
    description = string,
    file_url = string
    type = string
  }))
  default = []
  description = "List of content library items to import into the lobster content library"
}
