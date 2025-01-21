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

  cluster_name = var.dns
  #   cluster_domain   = "cluster.dummy.com.local"
  #   cluster_api_host = "kube.dummy.com"

  firewall_use_current_ip = false
  #   firewall_use_current_ip = false
  firewall_kube_api_source  = [local.executor_ip, hcloud_load_balancer.load_balancer.ipv4]
  firewall_talos_api_source = [local.executor_ip, hcloud_load_balancer.load_balancer.ipv4]

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

  #   network_ipv4_cidr = "10.0.0.0/16"
  #   node_ipv4_cidr    = "10.0.1.0/24"
  #   pod_ipv4_cidr     = "10.0.16.0/20"
  #   service_ipv4_cidr = "10.0.8.0/21"

  kubelet_extra_args = {
    # TODO see https://www.talos.dev/v1.9/kubernetes-guides/configuration/local-storage/#local-path-provisioner
    # extraMounts = jsonencode({
    #   destination = "/var/local-path-provisioner"
    #   type        = "bind"
    #   source      = "/var/local-path-provisioner"
    #   options = [
    #     "bind",
    #     "rshared",
    #     "rw"
    #   ]
    # })
  }

  extraManifests = [ # TODO probably not useful for applying storage-class yaml
  ]
}

output "talosconfig" {
  value     = module.talos.talosconfig
  sensitive = true
}

output "kubeconfig" {
  value     = module.talos.kubeconfig
  sensitive = true
}