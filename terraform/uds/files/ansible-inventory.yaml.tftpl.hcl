controlplane:
  hosts:
%{ for host in control_plane_ips }
    ${host}:
%{ endfor ~}
workers:
  hosts:
%{ for host in worker_node_ips }
    ${host}:
%{ endfor ~}
