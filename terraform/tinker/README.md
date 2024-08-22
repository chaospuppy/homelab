# base
The purpose of this module is to initialize the base vSphere components.  The base components include resources such as a
Compute Cluster, a Distrubted Virtual Switch, a Distributed Port Group, vNICs, a Datastore Cluster,
and Content Libraries.

## External Requirements
This module assumes the following prerequisites are satisfied:
- An existing vSphere instance is reachable
- The vSphere instance has at least one Datacenter defined

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_vsphere"></a> [vsphere](#requirement\_vsphere) | >= 2.8.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_vsphere"></a> [vsphere](#provider\_vsphere) | >= 2.8.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [vsphere_compute_cluster.this](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/resources/compute_cluster) | resource |
| [vsphere_content_library.uds_pub](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/resources/content_library) | resource |
| [vsphere_content_library.uds_sub](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/resources/content_library) | resource |
| [vsphere_datastore_cluster.uds](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/resources/datastore_cluster) | resource |
| [vsphere_distributed_port_group.uds](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/resources/distributed_port_group) | resource |
| [vsphere_distributed_virtual_switch.uds](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/resources/distributed_virtual_switch) | resource |
| [vsphere_vmfs_datastore.this](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/resources/vmfs_datastore) | resource |
| [vsphere_vnic.uds](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/resources/vnic) | resource |
| [vsphere_datacenter.this](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/data-sources/datacenter) | data source |
| [vsphere_host.this](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/data-sources/host) | data source |
| [vsphere_vmfs_disks.this](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/data-sources/vmfs_disks) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_unverified_ssl"></a> [allow\_unverified\_ssl](#input\_allow\_unverified\_ssl) | Set to false to force SSL verification of vSphere server certificate | `bool` | `true` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | n/a | `string` | `"box"` | no |
| <a name="input_drs_automation_level"></a> [drs\_automation\_level](#input\_drs\_automation\_level) | Set the automation level for DRS if enabled | `string` | `"fullyAutomated"` | no |
| <a name="input_drs_enabled"></a> [drs\_enabled](#input\_drs\_enabled) | Set to false to disable DRS managment of new vsphere cluster. | `bool` | `true` | no |
| <a name="input_esxi_hosts"></a> [esxi\_hosts](#input\_esxi\_hosts) | List of ESXI hosts | `list(string)` | <pre>[<br>  "esxi1",<br>  "esxi2",<br>  "esxi3"<br>]</pre> | no |
| <a name="input_uds_cluster_name"></a> [uds\_cluster\_name](#input\_uds\_cluster\_name) | Name of the vsphere cluster to create. | `string` | `"UDS_CC"` | no |
| <a name="input_uds_content_library_auth_method"></a> [uds\_content\_library\_auth\_method](#input\_uds\_content\_library\_auth\_method) | The authentication method used by subscriber content libraries to authenticate with the publisher | `string` | `"NONE"` | no |
| <a name="input_uds_content_library_auth_password"></a> [uds\_content\_library\_auth\_password](#input\_uds\_content\_library\_auth\_password) | Password used for auth with publication content library | `string` | `null` | no |
| <a name="input_uds_content_library_auth_username"></a> [uds\_content\_library\_auth\_username](#input\_uds\_content\_library\_auth\_username) | Username used for auth with publication content library | `string` | `null` | no |
| <a name="input_uds_content_library_description"></a> [uds\_content\_library\_description](#input\_uds\_content\_library\_description) | Description for Content library used to store VM media such as ISOs and OVFs | `string` | `"Content library used to store VM media such as ISOs and OVFs"` | no |
| <a name="input_uds_content_library_name_prefix"></a> [uds\_content\_library\_name\_prefix](#input\_uds\_content\_library\_name\_prefix) | Name for Content library used to store VM media such as ISOs and OVFs | `string` | `"UDS_CL"` | no |
| <a name="input_uds_content_library_pub_enabled"></a> [uds\_content\_library\_pub\_enabled](#input\_uds\_content\_library\_pub\_enabled) | Determines if the publish content library can be subscribed to, and consequently if subscription content libraries are created | `bool` | `true` | no |
| <a name="input_uds_content_library_sub_auto_sync"></a> [uds\_content\_library\_sub\_auto\_sync](#input\_uds\_content\_library\_sub\_auto\_sync) | Determines if the publish content library should be automatically synced to subscribed content libraries | `bool` | `true` | no |
| <a name="input_uds_content_library_sub_on_demand"></a> [uds\_content\_library\_sub\_on\_demand](#input\_uds\_content\_library\_sub\_on\_demand) | Determines if the publish content library should be synced to subscribed content libraries on-demand | `bool` | `false` | no |
| <a name="input_uds_datacenter_name"></a> [uds\_datacenter\_name](#input\_uds\_datacenter\_name) | Name of the target datacenter | `string` | `"UDS_DC"` | no |
| <a name="input_uds_datastore_cluster_name"></a> [uds\_datastore\_cluster\_name](#input\_uds\_datastore\_cluster\_name) | Name of the vsphere datastore to create. | `string` | `"UDS_DSC"` | no |
| <a name="input_uds_datastore_sdrs_enabled"></a> [uds\_datastore\_sdrs\_enabled](#input\_uds\_datastore\_sdrs\_enabled) | Set to true to enable SDRS on the UDS datastore cluster | `bool` | `true` | no |
| <a name="input_uds_distributed_port_group_name"></a> [uds\_distributed\_port\_group\_name](#input\_uds\_distributed\_port\_group\_name) | Name for the created UDS vswitch | `string` | `"uds-pg"` | no |
| <a name="input_uds_distributed_vswitch_active_uplinks"></a> [uds\_distributed\_vswitch\_active\_uplinks](#input\_uds\_distributed\_vswitch\_active\_uplinks) | List of active uplinks to assign for the UDS distributed vswitch | `list(string)` | <pre>[<br>  "uplink1"<br>]</pre> | no |
| <a name="input_uds_distributed_vswitch_name"></a> [uds\_distributed\_vswitch\_name](#input\_uds\_distributed\_vswitch\_name) | Name for the created UDS vswitch | `string` | `"uds-vswitch"` | no |
| <a name="input_uds_distributed_vswitch_standby_uplinks"></a> [uds\_distributed\_vswitch\_standby\_uplinks](#input\_uds\_distributed\_vswitch\_standby\_uplinks) | List of standby uplinks to assign to the UDS distributed vswitch | `list(string)` | `[]` | no |
| <a name="input_uds_network_cidr"></a> [uds\_network\_cidr](#input\_uds\_network\_cidr) | CIDR of the ESXi host network.  Used to calculate a new ipv4 addresses for the UDS VM network | `string` | `"192.168.20.0/23"` | no |
| <a name="input_uds_network_dhcp_enabled"></a> [uds\_network\_dhcp\_enabled](#input\_uds\_network\_dhcp\_enabled) | Set to true to allow UDS VMs to be assigned an address from previously configured DHCP | `bool` | `false` | no |
| <a name="input_uds_network_gateway_ip"></a> [uds\_network\_gateway\_ip](#input\_uds\_network\_gateway\_ip) | IP Address for UDS VM Network Gateway | `string` | `"0.0.0.0"` | no |
| <a name="input_uds_vmfs_disk_filter"></a> [uds\_vmfs\_disk\_filter](#input\_uds\_vmfs\_disk\_filter) | Regex filter used to identify disks used for UDS vsphere storage cluster | `string` | `""` | no |
| <a name="input_vsphere_password"></a> [vsphere\_password](#input\_vsphere\_password) | Password used to authenticate with vSphere API | `string` | n/a | yes |
| <a name="input_vsphere_server"></a> [vsphere\_server](#input\_vsphere\_server) | FQDN or IP of the vSphere API | `string` | `"vcenter.box"` | no |
| <a name="input_vsphere_username"></a> [vsphere\_username](#input\_vsphere\_username) | User used to authenticate with vSphere API | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_hosts"></a> [hosts](#output\_hosts) | n/a |
| <a name="output_uds_network"></a> [uds\_network](#output\_uds\_network) | n/a |
| <a name="output_uds_pub_content_library"></a> [uds\_pub\_content\_library](#output\_uds\_pub\_content\_library) | n/a |
| <a name="output_vnics"></a> [vnics](#output\_vnics) | n/a |
| <a name="output_vsphere_hosts"></a> [vsphere\_hosts](#output\_vsphere\_hosts) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
