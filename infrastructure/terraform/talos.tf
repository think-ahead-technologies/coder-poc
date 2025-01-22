variable "HCLOUD_TOKEN" {
  type      = string
  sensitive = true
}

data "http" "myip" {
  url = "https://ipv4.icanhazip.com"
}

locals {
  executor_ip = chomp(data.http.myip.response_body)
}

module "talos" {
  source  = "hcloud-talos/talos/hcloud"
  version = "2.13.1"

  talos_version      = "v1.9.1"
  kubernetes_version = "1.32.0"
  cilium_version     = "1.16.5"

  hcloud_token = var.HCLOUD_TOKEN

  cluster_name = local.dns
  #   cluster_domain   = "cluster.dummy.com.local"
  #   cluster_api_host = "kube.dummy.com"

  firewall_use_current_ip = false
  firewall_kube_api_source  = [
    local.executor_ip,
    hcloud_load_balancer.load_balancer.ipv4
  ]
  firewall_talos_api_source = [
    local.executor_ip,
    hcloud_load_balancer.load_balancer.ipv4
  ]

  extra_firewall_rules = [
    {
      description = "Allow Incoming HTTP requests"
      direction   = "in"
      protocol    = "tcp"
      port        = "any"
      source_ips  = [local.executor_ip, hcloud_load_balancer.load_balancer.ipv4]
    }
  ]

  datacenter_name = var.datacenter

  disable_x86 = true

  control_plane_server_type = var.control_plane_type
  control_plane_count       = var.control_plane_count

  worker_server_type = var.worker_type
  worker_count       = var.worker_count
}

output "talosconfig" {
  value     = module.talos.talosconfig
  sensitive = true
}

output "kubeconfig" {
  value     = module.talos.kubeconfig
  sensitive = true
}