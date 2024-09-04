lobster_hosts = [
    "192.168.0.15"
]
lobster_vmfs_disk_filter = "^t10.NVMe.*"
content_library_items = [
  {
    name = "ubuntu22.04-server"
    description = "ubuntu 22.0.4 server iso"
    file_url = "https://releases.ubuntu.com/jammy/ubuntu-22.04.4-live-server-amd64.iso"
    type = "iso"
  }
]

