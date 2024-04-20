# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # configure general VM
  config.vm.box = "ubuntu/jammy64"

  # configure master vm
  config.vm.define "master" do |master|
    master.vm.hostname = "master"
    master.vm.network "private_network", ip: "192.168.56.10"
  end

  # configure slave vm
  config.vm.define "slave" do |slave|
    slave.vm.hostname = "slave"
    slave.vm.network "private_network", ip: "192.168.56.11"
  end 

  # provision both vms
  config.vm.provision "shell", inline: <<-SHELL
  sudo apt-get update && sudo apt-get upgrade -y
  SHELL
end
