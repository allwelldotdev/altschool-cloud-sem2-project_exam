# AltSchool Cloud 2nd Semester Project Exam
Project Exam Summary: Automatically provision multiVMs (2 - master & slave), create bash script to deploy LAMP Stack on master vm/node, use Ansible to execute the bash script on slave vm/node.

## Extended Project Exam Questions
1. Automate the provisioning of two Ubuntu-based servers, named “Master” and “Slave”, using Vagrant.
2. On the Master node, create a bash script to automate the deployment of a LAMP (Linux, Apache, MySQL, PHP) stack.
    - This script should clone a [Laravel PHP application from GitHub](https://github.com/laravel/laravel), install all necessary packages, and configure Apache web server and MySQL. 
    - Ensure the bash script is reusable and readable.
3. Using an Ansible playbook:
    - Execute the bash script on the Slave node and verify that the PHP application is accessible through the VM’s IP address (take screenshot of this as evidence).
    - Create a cron job to check the server’s uptime every 12 am.

## Demonstration/Documentation of Project Solution

**For Question 1**

Defined two VMs in [Vagrantfile](/Vagrantfile), namely 'master' and 'slave', and assigned two static IPs to them; master - 192.168.56.10, slave - 192.168.56.11.

Vagrant up both VMs and checked the IP address for proof.

`Master VM - 192.168.56.10`

![Master VM](/assets/media/img-1.png)

`Slave VM - 192.168.56.11`

![Slave VM](/assets/media/img-2.png)

**For Question 2**

