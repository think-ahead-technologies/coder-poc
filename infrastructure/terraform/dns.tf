
data "hetznerdns_zone" "think_ahead" {
  name = "think-ahead.dev"
}

resource "hetznerdns_record" "coder" {
  zone_id = data.hetznerdns_zone.think_ahead.id
  name    = "coder"
  value   = hcloud_load_balancer.load_balancer.ipv4
  type    = "A"
  ttl     = 60
}

resource "hcloud_load_balancer" "load_balancer" {
  name               = "coder-load-balancer"
  load_balancer_type = "lb11"
  location           = var.zone
}

output "load-balancer-ip" {
  value = hcloud_load_balancer.load_balancer.ipv4
}

output "coder-dns" {
  value = "${hetznerdns_record.coder.name}.${data.hetznerdns_zone.think_ahead.name}"
}