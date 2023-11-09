pvt_key                   = "~/.ssh/id_rsa"     # private key location, so Terraform can use it to log in to new Droplets
pub_ssh_key               = "~/.ssh/id_rsa.pub" # public key location, so Terraform can use it to log in to new Droplets
digitalocean_ssh_key_name = "my-key"            # replace with your SSH key identifier in DO
vm_region                 = "fra1"              # replace with your preferred region, for example fra1
vm_size                   = "g-8vcpu-32gb"      # replace with your preferred Droplet size, for example "s-8vcpu-16gb". For more information, see https://slugs.do-api.dev/ and https://www.digitalocean.com/pricing/
