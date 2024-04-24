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

### For Question 1

Defined two VMs in [Vagrantfile](/Vagrantfile), namely 'master' and 'slave', and assigned two static IPs to them; master - 192.168.56.10, slave - 192.168.56.11.

Vagrant up both VMs and checked the IP address for proof.

`Master VM - 192.168.56.10`

![Master VM](/assets/media/img-1.png)

`Slave VM - 192.168.56.11`

![Slave VM](/assets/media/img-2.png)

### For Question 2

Wrote the **bash script** to be completely automated without ANY interactions (I stress 'ANY interactions', which means, once started, the bash script will run uninterrupted till completion). See [bash script](/scripts/deploy-LAMP-stack.sh).

To make the bash script more reusable, I created a **config file** that stores the database variables needed to run the bash script. See [config file](/assets/config/deploy-LAMP-stack.cfg).

The bash script sources/calls the variables from the config file into itself and temporarily stores them for use.

### For Question 3

Created [Ansible playbook](/scripts/ansible/playbook.yaml) to execute bash script on Slave node, ran it, and it ran successfully. See the images below for proof.

**UPDATE:** I discovered, when I tried cloning my project repo from GitHub and executing my Ansible playbook, that my bash script wouldn't run. I found that the problem was Windows line endings [or carriage returns (CR)] not working on Unix-like systems. So, I updated the Master VM provisioning and Ansible playbook to solve this problem and eliminate the bug.
Now, if you clone my repo into your local machine and run my code it would work 'on your machine'.
See new Ansible playbook execution result below.

`Ansible playbook ran successfully`

![Ansible playbook run](/assets/media/ansible-playbook-run-2.png)

Verified that PHP Laravel application is accessible through Slave VM's IP address: 192.168.56.11

`LAMP stack proof: Slave VM - 192.168.56.11`

![LAMP stack proof: Slave VM - 192.168.56.11](/assets/media/lamp-stack-proof-slavevm.png)

Created a cron job with Ansible playbook to check server’s (Slave VM) uptime every 12 am. Then ran `crontab -l` in shell to check cron job list. See image below.

`Cron job to check server's uptime every 12 am`

![Cron job checked through crontab list](/assets/media/crontab.png)



