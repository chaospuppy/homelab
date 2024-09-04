# core
The purpose of this module is to provision an RKE2 cluster utilizing the vSphere resources outlined
in the `base` module.

## Requirements
This module assumes the following prerequisites are satisfied:
- The resources provided by the `base` module are present in vSphere
- The Defense Unicorns [UDS RKE2 Image Builder](https://github.com/defenseunicorns/uds-rke2-image-builder/tree/main) repository has been
run to provide VM images with UDS dependencies pre-installed

## Usage

example uds runner usage (preferred):

``` bash
# from the root of the repo

export ENV=dev
#initial runs
uds run terraform-one-time-bootstrap-per-env --set ENV=$ENV

#subsequent runs for $ENV
uds run terraform-apply-aws-bootstrap --set ENV=$ENV

# re-init to use a different ENV and also s3 backend
export ENV=stg
uds run terraform-backend-reconfigure-init-aws-bootstrap  --set ENV=$ENV

```

example terraform usage:

``` bash
# from the root of this module

root_module=base

pushd "${root_module}"
terraform init

# var-file path relative to current working directory
terraform apply -auto-approve
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.6.2 |
| <a name="requirement_vsphere"></a> [vsphere](#requirement\_vsphere) | >= 2.8.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.6.2 |
| <a name="provider_vsphere"></a> [vsphere](#provider\_vsphere) | >= 2.8.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [random_password.rke2_token](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [vsphere_folder.uds](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/resources/folder) | resource |
| [vsphere_virtual_machine.uds_control_plane](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/resources/virtual_machine) | resource |
| [vsphere_virtual_machine.uds_worker](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/resources/virtual_machine) | resource |
| [vsphere_compute_cluster.uds](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/data-sources/compute_cluster) | data source |
| [vsphere_datacenter.uds](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/data-sources/datacenter) | data source |
| [vsphere_datastore_cluster.uds](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/data-sources/datastore_cluster) | data source |
| [vsphere_network.uds](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/data-sources/network) | data source |
| [vsphere_virtual_machine.template](https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/data-sources/virtual_machine) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_unverified_ssl"></a> [allow\_unverified\_ssl](#input\_allow\_unverified\_ssl) | Set to false to force SSL verification of vSphere server certificate | `bool` | `true` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | n/a | `string` | `"box"` | no |
| <a name="input_persistent_admin_password"></a> [persistent\_admin\_password](#input\_persistent\_admin\_password) | n/a | `string` | n/a | yes |
| <a name="input_persistent_admin_username"></a> [persistent\_admin\_username](#input\_persistent\_admin\_username) | n/a | `string` | n/a | yes |
| <a name="input_uds_cluster_name"></a> [uds\_cluster\_name](#input\_uds\_cluster\_name) | Name of the vsphere cluster to create. | `string` | `"UDS_CC"` | no |
| <a name="input_uds_control_plane_cpus"></a> [uds\_control\_plane\_cpus](#input\_uds\_control\_plane\_cpus) | Number of CPUs to make available to UDS control plane nodes | `number` | `4` | no |
| <a name="input_uds_control_plane_disk_size"></a> [uds\_control\_plane\_disk\_size](#input\_uds\_control\_plane\_disk\_size) | Size of control plane disk in GB | `number` | `40` | no |
| <a name="input_uds_control_plane_memory"></a> [uds\_control\_plane\_memory](#input\_uds\_control\_plane\_memory) | Amount of memory, in MB, to make available to UDS control plane nodes | `number` | `4096` | no |
| <a name="input_uds_control_plane_node_count"></a> [uds\_control\_plane\_node\_count](#input\_uds\_control\_plane\_node\_count) | Number of control plane nodes to provision | `number` | `1` | no |
| <a name="input_uds_datacenter_name"></a> [uds\_datacenter\_name](#input\_uds\_datacenter\_name) | Name of the target datacenter | `string` | `"UDS_DC"` | no |
| <a name="input_uds_datastore_cluster_name"></a> [uds\_datastore\_cluster\_name](#input\_uds\_datastore\_cluster\_name) | Name of the vsphere datastore to create. | `string` | `"UDS_DSC"` | no |
| <a name="input_uds_disk_label_prefix"></a> [uds\_disk\_label\_prefix](#input\_uds\_disk\_label\_prefix) | Prefix for disk label attached to control plane disk | `string` | `"uds"` | no |
| <a name="input_uds_disk_thin_provisioned"></a> [uds\_disk\_thin\_provisioned](#input\_uds\_disk\_thin\_provisioned) | Determines if UDS node disks are thin provisioned | `bool` | `false` | no |
| <a name="input_uds_guest_os"></a> [uds\_guest\_os](#input\_uds\_guest\_os) | Guest OS type for the UDS Kubernetes node VMs | `string` | `"ubuntu64Guest"` | no |
| <a name="input_uds_network_adapter_type"></a> [uds\_network\_adapter\_type](#input\_uds\_network\_adapter\_type) | Type of network adapter to attach to UDS nodes | `string` | `"vmxnet3"` | no |
| <a name="input_uds_network_name"></a> [uds\_network\_name](#input\_uds\_network\_name) | Name of the UDS network | `string` | `"uds_pg"` | no |
| <a name="input_uds_vm_folder"></a> [uds\_vm\_folder](#input\_uds\_vm\_folder) | Name for the folder in which to place the UDS nodes | `string` | `"UDS"` | no |
| <a name="input_uds_worker_cpus"></a> [uds\_worker\_cpus](#input\_uds\_worker\_cpus) | Number of CPUs to make available to UDS worker nodes | `number` | `4` | no |
| <a name="input_uds_worker_disk_size"></a> [uds\_worker\_disk\_size](#input\_uds\_worker\_disk\_size) | Size of worker disk in GB | `number` | `40` | no |
| <a name="input_uds_worker_memory"></a> [uds\_worker\_memory](#input\_uds\_worker\_memory) | Amount of memory, in MB, to make available to UDS worker nodes | `number` | `4096` | no |
| <a name="input_uds_worker_node_count"></a> [uds\_worker\_node\_count](#input\_uds\_worker\_node\_count) | Number of control plane nodes to provision | `number` | `1` | no |
| <a name="input_vm_template_name"></a> [vm\_template\_name](#input\_vm\_template\_name) | The name of the VM Template to use for the RKE2 nodes | `string` | `"uds_node_ubuntu_rke2"` | no |
| <a name="input_vsphere_password"></a> [vsphere\_password](#input\_vsphere\_password) | Password used to authenticate with vSphere API | `string` | n/a | yes |
| <a name="input_vsphere_server"></a> [vsphere\_server](#input\_vsphere\_server) | FQDN or IP of the vSphere API | `string` | `"vcenter.box"` | no |
| <a name="input_vsphere_username"></a> [vsphere\_username](#input\_vsphere\_username) | User used to authenticate with vSphere API | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
