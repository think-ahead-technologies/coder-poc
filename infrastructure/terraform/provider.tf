
terraform {

  required_providers {

    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }

    hetznerdns = {
      source  = "timohirt/hetznerdns"
      version = "2.1.0"
    }

    # onepassword = {
    #   source = "1Password/onepassword"
    #   version = "~> 2.0.0"
    # }

  }
  required_version = ">= 1.0"
}