terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "digitalocean_token" {
  type        = string
  description = "Digital Ocean API token"
}
variable "digitalocean_ssh_key_name" {
  type        = string
  description = "name of ssh key registered in Digital Ocean"
}
variable "pvt_key" {
  type        = string
  description = "path to rsa private key"
}
variable "pub_ssh_key" {
  type        = string
  description = "path to rsa public key, that will be copied to VMs"
}
variable "vm_region" {
  type        = string
  description = "region where VM will be created"
}
variable "vm_size" {
  type        = string
  description = "size of VM"
}

provider "digitalocean" {
  token = var.digitalocean_token
}

data "digitalocean_ssh_key" "terraform" {
  name = var.digitalocean_ssh_key_name
}

variable "lab_image" {
  description = "Containerlab image details"
  type = object({
    local_path = string
    image_name = string
    tar_name   = string
  })
  default = {
    local_path = "~/Downloads/cEOS-lab-4.30.1F.tar"
    image_name = "ceos:4.30.1F"
    tar_name   = "cEOS-lab-4.30.1F.tar"
  }
}
