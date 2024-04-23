#!/bin/bash

# Check for existing SSH keys and generate a new one if none exists
if [ ! -f "/home/vagrant/.ssh/id_rsa_slavevm" ]; then
  echo "Generating SSH key..."
  sudo -u vagrant ssh-keygen -t rsa -b 4096 -C "slave vm pka created by Allwell 220424" -N "" -f "/home/vagrant/.ssh/id_rsa_slavevm"
  echo "SSH key generated."
  sudo -u vagrant chmod 400 /home/vagrant/.ssh/id_rsa_slavevm
else
  echo "SSH key already exists."
fi