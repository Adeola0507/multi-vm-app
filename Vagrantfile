# -*- mode: ruby -*-
# vi: set ft=ruby :

# Multi-VM application stack:
#   web (192.168.56.10) -> api (192.168.56.11) -> db (192.168.56.12)
#
# All three VMs share a private host-only network (192.168.56.0/24)
# and communicate by IP address + port.

Vagrant.configure("2") do |config|
  config.vm.box = "spox/ubuntu-arm"   # ubuntu/jammy64 for windows 
  
  # Speed up provisioning: don't auto-update the box every time
  config.vm.box_check_update = false

  # ---------- Database VM ----------
  config.vm.define "db" do |db|
    db.vm.hostname = "db"
    db.vm.network "private_network", ip: "192.168.56.12"

    db.vm.provider "virtualbox" do |vb|
      vb.name   = "vm-db"
      vb.memory = 512
      vb.cpus   = 1
    end

    db.vm.provision "shell", path: "provision/db.sh"
  end

  # ---------- Backend API VM ----------
  config.vm.define "api" do |api|
    api.vm.hostname = "api"
    api.vm.network "private_network", ip: "192.168.56.11"

    api.vm.provider "virtualbox" do |vb|
      vb.name   = "vm-api"
      vb.memory = 512
      vb.cpus   = 1
    end

    api.vm.provision "shell", path: "provision/api.sh"
  end

  # ---------- Frontend Web VM ----------
  config.vm.define "web" do |web|
    web.vm.hostname = "web"
    web.vm.network "private_network", ip: "192.168.56.10"

    # Make the web tier reachable from your host browser at http://localhost:8080
    web.vm.network "forwarded_port", guest: 80, host: 8080

    web.vm.provider "virtualbox" do |vb|
      vb.name   = "vm-web"
      vb.memory = 512
      vb.cpus   = 1
    end

    web.vm.provision "shell", path: "provision/web.sh"
  end
end
