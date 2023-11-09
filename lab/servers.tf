resource "digitalocean_droplet" "vm" {
  count  = 4
  image  = "ubuntu-22-04-x64"
  name   = format("%s-%s", "nornir-lab", count.index)
  region = var.vm_region
  size   = var.vm_size
  ssh_keys = [
    data.digitalocean_ssh_key.terraform.id
  ]
  tags = [
    "nornir-playground"
  ]

  connection {
    host        = self.ipv4_address
    user        = "root"
    type        = "ssh"
    private_key = file(var.pvt_key)
    timeout     = "2m"
  }

  provisioner "file" {
    source      = var.pub_ssh_key
    destination = "/tmp/temp.pub"
  }

  provisioner "file" {
    source      = "simple_topology.yml"
    destination = "/tmp/simple_topology.yml"
  }



  provisioner "remote-exec" {
    inline = [
      # Set up SSH keys
      "cat /tmp/temp.pub >> ~/.ssh/authorized_keys",
      "sudo apt-get update -y",
      "sleep 60",

      # Install Docker
      "curl -fsSL https://get.docker.com -o get-docker.sh",
      "sudo sh get-docker.sh",
      "sleep 60",

      # Install containerlab
      "bash -c \"$(curl -sL https://get.containerlab.dev)\"",
      "sleep 150",

      # Install Socat
      "DEBIAN_FRONTEND=noninteractive apt-get install -y -qq socat",
    ]
  }

  # Import cEOS image
  provisioner "file" {
    source      = var.lab_image.local_path
    destination = "/tmp/${var.lab_image.tar_name}"
  }

  provisioner "remote-exec" {
    inline = [
      "docker import /tmp/${var.lab_image.tar_name} ${var.lab_image.image_name}",
    ]
  }


  # Prepare the lab
  provisioner "remote-exec" {
    inline = [
      "containerlab deploy --topo /tmp/simple_topology.yml",
    ]
  }

  # SOCAT

  provisioner "remote-exec" {
    inline = [
      "socat TCP-LISTEN:12001,reuseaddr,fork TCP:ceos-01:22 & ",
      "socat TCP-LISTEN:12002,reuseaddr,fork TCP:ceos-02:22 & ",
      "socat TCP-LISTEN:12003,reuseaddr,fork TCP:ceos-03:22 & ",
      "socat TCP-LISTEN:12004,reuseaddr,fork TCP:ceos-04:22 & ",
      "socat TCP-LISTEN:12005,reuseaddr,fork TCP:ceos-05:22 & ",
      "socat TCP-LISTEN:12006,reuseaddr,fork TCP:ceos-06:22 & ",
      "socat TCP-LISTEN:12007,reuseaddr,fork TCP:ceos-07:22 & ",
      "socat TCP-LISTEN:12008,reuseaddr,fork TCP:ceos-08:22 & ",
      "socat TCP-LISTEN:12009,reuseaddr,fork TCP:ceos-09:22 & ",
      "socat TCP-LISTEN:12010,reuseaddr,fork TCP:ceos-10:22 & ",
      "socat TCP-LISTEN:12011,reuseaddr,fork TCP:ceos-11:22 & ",
      "socat TCP-LISTEN:12012,reuseaddr,fork TCP:ceos-12:22 & ",
      "socat TCP-LISTEN:12013,reuseaddr,fork TCP:ceos-13:22 & ",
      "socat TCP-LISTEN:12014,reuseaddr,fork TCP:ceos-14:22 & ",
      "socat TCP-LISTEN:12015,reuseaddr,fork TCP:ceos-15:22 & ",
      "socat TCP-LISTEN:12016,reuseaddr,fork TCP:ceos-16:22 & ",
      "socat TCP-LISTEN:12017,reuseaddr,fork TCP:ceos-17:22 & ",
      "socat TCP-LISTEN:12018,reuseaddr,fork TCP:ceos-18:22 & ",
      "socat TCP-LISTEN:12019,reuseaddr,fork TCP:ceos-19:22 & ",
      "socat TCP-LISTEN:12020,reuseaddr,fork TCP:ceos-20:22 & ",
      "socat TCP-LISTEN:12021,reuseaddr,fork TCP:ceos-21:22 & ",
      "socat TCP-LISTEN:12022,reuseaddr,fork TCP:ceos-22:22 & ",
      "socat TCP-LISTEN:12023,reuseaddr,fork TCP:ceos-23:22 & ",
      "socat TCP-LISTEN:12024,reuseaddr,fork TCP:ceos-24:22 & ",
      "socat TCP-LISTEN:12025,reuseaddr,fork TCP:ceos-25:22 & ",
      "socat TCP-LISTEN:12026,reuseaddr,fork TCP:ceos-26:22 & ",
      "socat TCP-LISTEN:12027,reuseaddr,fork TCP:ceos-27:22 & ",
      "socat TCP-LISTEN:12028,reuseaddr,fork TCP:ceos-28:22 & ",
    ]
  }

}

resource "digitalocean_firewall" "fw" {
  name = "fw-rules"

  droplet_ids = [for item in digitalocean_droplet.vm : item.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "8080"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "12000-12999"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "tcp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

output "ssh_commands" {
  value = [for item in digitalocean_droplet.vm : "ssh -o StrictHostKeyChecking=no -i ${var.pvt_key} root@${item.ipv4_address}"]
}
