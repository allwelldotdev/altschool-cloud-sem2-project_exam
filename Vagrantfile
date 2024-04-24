# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # configure general VM
  config.vm.box = "ubuntu/jammy64"

  # configure master vm
  config.vm.define "master" do |master|
    master.vm.hostname = "master"
    master.vm.network "private_network", ip: "192.168.56.10"

    # provision master vm
    master.vm.provision "shell", inline: <<-SHELL

    # Provision LAMP stack bash script into user directory
    sudo -u vagrant cp /vagrant/assets/config/deploy-LAMP-stack.cfg /home/vagrant
    sudo -u vagrant cp /vagrant/scripts/deploy-LAMP-stack.sh /home/vagrant
    sudo -u vagrant chmod +x /home/vagrant/deploy-LAMP-stack.sh
    sudo -u vagrant sed -i 's/\r$//' /home/vagrant/deploy-LAMP-stack.sh # remove Windows carriage returns (CR) - Ensure script runs on Linux VM
    
    # Install and configure Ansible
    sudo add-apt-repository --yes --update ppa:ansible/ansible
    sudo apt install ansible -y
    cd /etc/ansible/
    sudo mv ansible.cfg ansible.cfg_backup
    sudo ansible-config init --disabled -t all > ansible.cfg
    sudo sed -i "s/^;host_key_checking=True/host_key_checking=False/" /etc/ansible/ansible.cfg # Stop Ansible from interaction during ssh login - improve automation process

    # Provision Ansible files into user directory
    sudo -u vagrant cp -r /vagrant/scripts/ansible /home/vagrant
    SHELL

    # provision master vm: Generate SSH key-pair
    master.vm.provision "shell", path: "scripts/ssh_keygen.sh"
  end

  # configure slave vm
  config.vm.define "slave" do |slave|
    slave.vm.hostname = "slave"
    slave.vm.network "private_network", ip: "192.168.56.11"

    # provision slave vm
    slave.vm.provision "shell", inline: <<-SHELL

    # Secure SSH connection
    sudo sed -i "s/^#PermitRootLogin prohibit-password/PermitRootLogin prohibit-password/" /etc/ssh/sshd_config # Turn off password-enabled root ssh login
    sudo sed -i "s/^#PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config # Turn off password-enabled ssh login
    sudo systemctl restart ssh # Restart ssh service to enable config
    SHELL
  end 

  # provision both vms
  config.vm.provision "shell", inline: <<-SHELL

  # update system
  sudo apt-get update
  
  # Turn off restart of services - Change line 38 from "#$nrconf{restart} = 'i';" to "#$nrconf{restart} = 'a';"
  sudo apt-get install -y needrestart
  sudo sed -i "38s/#\\$nrconf{restart} = 'i';/#\\$nrconf{restart} = 'a';/" /etc/needrestart/needrestart.conf
  
  # Ensure SSH is installed & enabled
  sudo apt install openssh-server openssh-client -y
  SHELL
end
