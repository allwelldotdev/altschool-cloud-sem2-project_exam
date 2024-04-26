# Infrastructure automation: I reduced to just 2 steps the deployment of a LAMP stack + Laravel app using Bash Shell Scripting, Vagrant, and Ansible. Here's how I did it.

![AI generated image by ChatGPT Plus + DALL·E](/assets/media/blog/img-dalle.jpg "AI generated image by ChatGPT Plus + DALL·E")

Hi there, Cloud and DevOps Enthusiasts, Engineers, and readers, my name is Allwell and I’m currently learning Cloud Computing & Engineering. With this article, I aim to share with you how I automated the deployment of a LAMP stack (Linux, Apache, MySQL, PHP) and Laravel app using bash shell scripting, Vagrant, and Ansible, down to just two simple steps.

Automation can be defined as the simplification and streamlining of a process, where tasks that previously required multiple manual steps are configured to operate with minimal human intervention. This often involves using technology to execute tasks automatically, reducing the need for manual input to just a few or even a single step. The goal of automation is to increase efficiency, reduce errors, and free up human resources for more complex activities.

At a bootcamp I’m attending known as AltSchool Africa (learning Cloud/DevOps Engineering), for second semester exams, I was tasked to do the following:

---

**Project Exam Summary:** Automatically provision multiple VMs (Virtual Machines) (2 - master & slave), create bash script to deploy LAMP Stack on master vm/node, use Ansible to execute the bash script on slave vm/node.

**Extended Project Exam Question:** 

1. Automate the provisioning of two Ubuntu-based servers, named “Master” and “Slave”, using Vagrant.
2. On the Master node, create a bash script to automate the deployment of a LAMP stack (Linux, Apache, MySQL, PHP).
    a. This script should clone a [Laravel PHP application from GitHub](https://github.com/laravel/laravel), install all necessary packages, and configure Apache web server and MySQL.
    b. Ensure the bash script is reusable and readable.
3. Using an Ansible playbook:
    a. Execute the bash script on the Slave node and verify that the PHP application is accessible through the VM’s IP address (take a screenshot of this as evidence).
    b. Create a cronjob to check the server’s uptime every 12 am.

---

## Firing up my Virtual Machines (VMs)

Solution: I created, or in engineering terms; fired up, two virtual machines (vm) using a vm automation tool known as Vagrant.

Let’s call the host vm, **Master**, and the server vm, **Slave**.

After initializing a Vagrant box (a Vagrant term for ‘an OS instance’), I wrote the init file - Vagrantfile, as seen below (my Vagrantfile config):

```ruby
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

  # update system
  sudo apt-get update
  SHELL
end

```

- `config.vm.box = "ubuntu/jammy64"` This line states the operating system of the both vms is Ubuntu 22.04 LTS (Jammy Jellyfish).
- `config.vm.define "master" do |master|` & `config.vm.define "slave" do |slave|` These lines tell Vagrant to fire up two virtual machines, one called master and the other slave.
- `master.vm.network "private_network", ip: "192.168.56.10"` & `slave.vm.network "private_network", ip: "192.168.56.11"` These lines tell Vagrant to configure both vms with private static IPs so I can access them via a browser. The master vm is assigned the ip 192.168.56.10, while the slave vm is assigned the ip 192.168.56.11.
- There’s a huge part of the Vagrantfile code that is not visible yet, and that’s because the rest of the code is about provisioning for both vms, which I will talk about in detail later in this article. For now, let’s move on to writing the bash script to deploy a LAMP stack.

## The Bash Shell Script, or simply Bash Script.

The bash script was the major hurdle in this task because it was the lifeblood that was required for the entire operation to run. The rest of the tasks were mostly automation scripts and software. Below, I break down the bash script into bits (as much I can).

The task: Deploy a LAMP stack, clone the Laravel repo from GitHub, install all necessary packages, and configure the Apache web server, MySQL, and PHP.

```bash
#!/bin/bash

# Exit bash script upon any erors
set -e

# Define a function to run when an error occurs
error_handling() {
    echo "The script failed due to a fault"
    echo "Error on line $1 of bash script"
}

# Trap any ERR signal and call error_handling function with the line number
trap 'error_handling $LINENO' ERR

# ----------------------------------------------------------

# Source the 'deploy-LAMP-stack.cfg' configuration file
echo -e "\n###################################################"
echo "Sourcing 'deploy-LAMP-stack.cfg' configuration file..."
sleep 2

# Define path to the configuration file
CONFIG_FILE="$HOME/deploy-LAMP-stack.cfg"

# Check if the file exists, then source config file, or exit script
if [[ -f "$CONFIG_FILE" ]]; then
    # Source configuration file
    source $HOME/deploy-LAMP-stack.cfg
    echo "Configuration file loaded successfully..."
    echo -e "\n###################################################"
else
    echo "Configuration file does not exist in user's home directory"
    echo "Add configuration file 'deploy-LAMP-stack.cfg' to user's home directory - /home/user/"
    echo -e "\n###################################################"
    exit 1 # Exit the script with an exit/return status of 1 indicating an error
fi

# Ensure no interactive prompt during installation or while running script
export DEBIAN_FRONTEND=noninteractive

# Update Linux system package repo
echo -e "\n###################################################"
echo "Updating and upgrading your system..."
echo -e "\n###################################################"
sudo apt update -y

# Apache2 Installation
echo -e "\n###################################################"
echo "Installing Apache2..."
echo -e "\n###################################################"
sudo apt install apache2  -y

# Enable mod_rewrite for Apache2
sudo a2enmod rewrite

# Adjust Firewall to Allow Web Traffic
sudo ufw allow in "Apache Full"

# MySQL Installation
echo -e "\n###################################################"
echo "Installing MySQL..."
echo -e "\n###################################################"
sudo apt install mysql-server -y

# Secure MySQL Installation
echo -e "\n###################################################"
echo "Securing SQL Installation"
echo -e "\n###################################################"
sudo mysql_secure_installation <<EOF

y
n   
y
y
y
y
EOF

# PHP Installation
echo -e "\n###################################################"
echo "Installing PHP 8.2..."
echo -e "\n###################################################"
sudo add-apt-repository -y ppa:ondrej/php
sudo apt update
sudo apt install php8.2 -y

# PHP 8.2 Extensions Installation
echo -e "\n###################################################"
echo "Installing required PHP 8.2 extensions..."
echo -e "\n###################################################"
sudo apt install php8.2-cli php8.2-common php8.2-fpm php8.2-mysql php8.2-zip php8.2-gd php8.2-mbstring php8.2-curl php8.2-xml php8.2-bcmath php8.2-intl php8.2-zip libapache2-mod-php8.2 git unzip -y

# Restart Apache to load new config
sudo systemctl restart apache2

# Composer Installation
echo -e "\n###################################################"
echo "Installing Composer..."
echo -e "\n###################################################"

curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer --quiet

# Clone Laravel project from GitHub
echo -e "\n###################################################"
echo "Cloning Laravel from GitHub..."
echo -e "\n###################################################"
cd /var/www/html
sudo git clone https://github.com/laravel/laravel.git
cd laravel

# Composer Dependencies Installation
echo -e "\n###################################################"
echo "Installing Composer dependencies..."
echo -e "\n###################################################"
sudo composer install --no-interaction --prefer-dist --optimize-autoloader --working-dir=/var/www/html/laravel

# Setup MySQL Database
echo -e "\n###################################################"
echo "Setting up MySQL database..."
echo -e "\n###################################################"
sudo mysql -u root -p$DBPASS <<MYSQL_SCRIPT
CREATE DATABASE $DBNAME;
CREATE USER '$DBUSER'@'localhost' IDENTIFIED BY '$DBPASS';
GRANT ALL PRIVILEGES ON $DBNAME.* TO '$DBUSER'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

# Set permissions for Laravel storage and bootstrap cache directories
echo -e "\n###################################################"
echo "Setting permissions for Laravel, storage and bootstrap cache directories..."
echo -e "\n###################################################"
sudo chown -R www-data:www-data /var/www/html/laravel
sudo chmod -R 775 /var/www/html/laravel/storage /var/www/html/laravel/bootstrap/cache

# Setup Laravel environment file
echo -e "\n###################################################"
echo "Configuring Laravel environment..."
echo -e "\n###################################################"
sudo cp .env.example .env
sudo sed -i "s/DB_CONNECTION=sqlite/DB_CONNECTION=mysql/" .env
sudo sed -i 's/^# DB_HOST=127.0.0.1/DB_HOST=127.0.0.1/' .env
sudo sed -i 's/^# DB_PORT=3306/DB_PORT=3306/' .env
sudo sed -i "s/^# DB_DATABASE=laravel/DB_DATABASE=$DBNAME/" .env
sudo sed -i "s/^# DB_USERNAME=root/DB_USERNAME=$DBUSER/" .env
sudo sed -i "s/^# DB_PASSWORD=/DB_PASSWORD=$DBPASS/" .env
php artisan migrate

# Clear and cache Laravel Artisan configurations
echo "Clearing and caching configurations..."
php artisan config:clear
php artisan cache:clear

# Generate Laravel key
echo -e "\n###################################################"
echo "Generating Laravel key..."
echo -e "\n###################################################"
sudo php artisan key:generate

# Configure Apache to serve the Laravel project
echo -e "\n###################################################"
echo "Configuring Apache to serve Laravel..."
echo -e "\n###################################################"
sudo tee /etc/apache2/sites-available/laravel.conf <<EOF
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html/laravel/public
    <Directory /var/www/html/laravel/public>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

# Enable the Laravel site
sudo a2ensite laravel.conf
sudo a2dissite 000-default.conf
sudo systemctl restart apache2

# LAMP stack + Laravel deployment: success
echo -e "\n###################################################"
echo "LAMP stack and Laravel are installed."
echo -e "\n###################################################"
echo "Script executed successfully."

```

Let’s call the bash script “deploy-LAMP-stack.sh”.

My goal for creating this script was to ensure it fully ran automatically, on its own, without any human input, prompt, or type interactions. I was thinking of a situation where I want to configure multiple vms at one go and want to fire them all up just by clicking the play button, and be certain about the safety and accuracy of the operation. This initiative forced me to make this bash script my own and tweak it beyond requirements to match my goal.

Here’s how I achieved that.

- To ensure the script is built to be reliable with zero interaction, I set the script to exit upon any errors and inserted an error handler function to catch the error line number, upon runtime, and display it to me so I can fix it in dev mode.

```bash
# Exit bash script upon any erors
set -e

# Define a function to run when an error occurs
error_handling() {
    echo "The script failed due to a fault"
    echo "Error on line $1 of bash script"
}

# Trap any ERR signal and call error_handling function with the line number
trap 'error_handling $LINENO' ERR
```

- Though, I didn’t want to, I concluded that I may have to create an external config file that contained the user-input variables required to run the script for things like setting up the MySQL database. Remember, I did this in the bid to ensure no interactivity in runtime but also ensure security of user input. Let’s call the external config file “deploy-LAMP-stack.cfg”.

```
# Configuration file for 'deploy-LAMP-stack.sh' shell script
DBNAME="laravel_db"
DBUSER="laravel_user"
DBPASS="laravel_pass"
```

- I sourced the variables assigned in the external config file into the script and wrote an ‘if’ statement to check if the file exists then source the variables and run the script, otherwise, if the file does not exist, echo (or post) to runtime that the file does not exit and request it be inserted for script to run.
- `sleep 2` I added this line to make it seem like the script was taking time (just 2 seconds) to search for the external config file. A touch of user experience there. Haha.

```bash
# Source the 'deploy-LAMP-stack.cfg' configuration file
echo -e "\n###################################################"
echo "Sourcing 'deploy-LAMP-stack.cfg' configuration file..."
sleep 2

# Define path to the configuration file
CONFIG_FILE="$HOME/deploy-LAMP-stack.cfg"

# Check if the file exists, then source config file, or exit script
if [[ -f "$CONFIG_FILE" ]]; then
    # Source configuration file
    source $HOME/deploy-LAMP-stack.cfg
    echo "Configuration file loaded successfully..."
    echo -e "\n###################################################"
else
    echo "Configuration file does not exist in user's home directory"
    echo "Add configuration file 'deploy-LAMP-stack.cfg' to user's home directory - /home/user/"
    echo -e "\n###################################################"
    exit 1 # Exit the script with an exit/return status of 1 indicating an error
fi
```

- This line was another attempt to ensure the script runs non-interactively—no user prompts, no type prompts, no popups; just run.

```bash
# Ensure no interactive prompt during installation or while running script
export DEBIAN_FRONTEND=noninteractive
```

- Then, the real fun begins. I start by updating my LinuxOS, which, remember, was set to Ubuntu 22.04 (Jammy Jellyfish) in the Vagrantfile. After which, I install and configure Apache2, MySQL, PHP, and PHP extensions. Mostly routine stuff.

```bash
# Update Linux system package repo
echo -e "\n###################################################"
echo "Updating and upgrading your system..."
echo -e "\n###################################################"
sudo apt update -y

# Apache2 Installation
echo -e "\n###################################################"
echo "Installing Apache2..."
echo -e "\n###################################################"
sudo apt install apache2  -y

# Enable mod_rewrite for Apache2
sudo a2enmod rewrite

# Adjust Firewall to Allow Web Traffic
sudo ufw allow in "Apache Full"

# MySQL Installation
echo -e "\n###################################################"
echo "Installing MySQL..."
echo -e "\n###################################################"
sudo apt install mysql-server -y

# Secure MySQL Installation
echo -e "\n###################################################"
echo "Securing SQL Installation"
echo -e "\n###################################################"
sudo mysql_secure_installation <<EOF

y
n   
y
y
y
y
EOF

# PHP Installation
echo -e "\n###################################################"
echo "Installing PHP 8.2..."
echo -e "\n###################################################"
sudo add-apt-repository -y ppa:ondrej/php
sudo apt update
sudo apt install php8.2 -y

# PHP 8.2 Extensions Installation
echo -e "\n###################################################"
echo "Installing required PHP 8.2 extensions..."
echo -e "\n###################################################"
sudo apt install php8.2-cli php8.2-common php8.2-fpm php8.2-mysql php8.2-zip php8.2-gd php8.2-mbstring php8.2-curl php8.2-xml php8.2-bcmath php8.2-intl php8.2-zip libapache2-mod-php8.2 git unzip -y

# Restart Apache to load new config
sudo systemctl restart apache2
```

- Then, Composer. It took me almost a whole day to resolve Composer issues. It kept on bugging my script. I eventually figured it out and installed Composer appropriately. This flag `--install-dir=/usr/local/bin` set the installation directory to an executable path. This ensures that running `composer` as an executable command is possible. This flag `--filename=composer` set the filename of the installed executable to ‘composer’. This flag `--quiet` set the installation to run noninteractively.

```bash
# Composer Installation
echo -e "\n###################################################"
echo "Installing Composer..."
echo -e "\n###################################################"

curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer --quiet
```

- Cloned the Laravel app from GitHub.

```bash
# Clone Laravel project from GitHub
echo -e "\n###################################################"
echo "Cloning Laravel from GitHub..."
echo -e "\n###################################################"
cd /var/www/html
sudo git clone https://github.com/laravel/laravel.git
cd laravel
```

- Installed Composer dependencies for the Laravel app. The Composer installer looks at the directory where the Laravel app is installed and reads the `composer.json` file to find dependency requirements for the app. Where it doesn’t see a dependency lock file (which locks the app dependencies to specifics for backwards compatibility and future proofing despite future updates to the Laravel app GitHub repo), that’s generally named a `composer.lock` file, the Composer Installer installs dependency requirements stated in the `composer.json` file (which are often latest dependency updates, which can in turn be troublesome for app reliability considering the bugs that are often found in latest, bleeding-edge, app updates).

```bash
# Composer Dependencies Installation
echo -e "\n###################################################"
echo "Installing Composer dependencies..."
echo -e "\n###################################################"
sudo composer install --no-interaction --prefer-dist --optimize-autoloader --working-dir=/var/www/html/laravel
```

- Setup MySQL Database with user input variables I stored in the external config file (remember). Set file permissions for Laravel storage and bootstrap cache directories. Setup the Laravel environment `.env` file. Clear and cache Laravel Artisan configurations. Generate a Laravel key to ensure the security of user sessions and other encrypted data.

```bash
# Setup MySQL Database
echo -e "\n###################################################"
echo "Setting up MySQL database..."
echo -e "\n###################################################"
sudo mysql -u root -p$DBPASS <<MYSQL_SCRIPT
CREATE DATABASE $DBNAME;
CREATE USER '$DBUSER'@'localhost' IDENTIFIED BY '$DBPASS';
GRANT ALL PRIVILEGES ON $DBNAME.* TO '$DBUSER'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

# Set permissions for Laravel storage and bootstrap cache directories
echo -e "\n###################################################"
echo "Setting permissions for Laravel, storage and bootstrap cache directories..."
echo -e "\n###################################################"
sudo chown -R www-data:www-data /var/www/html/laravel
sudo chmod -R 775 /var/www/html/laravel/storage /var/www/html/laravel/bootstrap/cache

# Setup Laravel environment file
echo -e "\n###################################################"
echo "Configuring Laravel environment..."
echo -e "\n###################################################"
sudo cp .env.example .env
sudo sed -i "s/DB_CONNECTION=sqlite/DB_CONNECTION=mysql/" .env
sudo sed -i 's/^# DB_HOST=127.0.0.1/DB_HOST=127.0.0.1/' .env
sudo sed -i 's/^# DB_PORT=3306/DB_PORT=3306/' .env
sudo sed -i "s/^# DB_DATABASE=laravel/DB_DATABASE=$DBNAME/" .env
sudo sed -i "s/^# DB_USERNAME=root/DB_USERNAME=$DBUSER/" .env
sudo sed -i "s/^# DB_PASSWORD=/DB_PASSWORD=$DBPASS/" .env
php artisan migrate

# Clear and cache Laravel Artisan configurations
echo "Clearing and caching configurations..."
php artisan config:clear
php artisan cache:clear

# Generate Laravel key
echo -e "\n###################################################"
echo "Generating Laravel key..."
echo -e "\n###################################################"
sudo php artisan key:generate
```

- Now, the final piece is where I configure the Apache2 web server to serve the Laravel project through the web port 80. This means, when you input the IP address of the vm—which we set in the Vagrantfile (remember)—you’ll be able to see the display homepage of the Laravel app. Let’s take note of the display homepage of the Laravel app being the test to certify if our entire script ran correctly, because every other step taken in this script was made to arrive at this point.

```bash
# Configure Apache to serve the Laravel project
echo -e "\n###################################################"
echo "Configuring Apache to serve Laravel..."
echo -e "\n###################################################"
sudo tee /etc/apache2/sites-available/laravel.conf <<EOF
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html/laravel/public
    <Directory /var/www/html/laravel/public>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

# Enable the Laravel site
sudo a2ensite laravel.conf
sudo a2dissite 000-default.conf
sudo systemctl restart apache2

# LAMP stack + Laravel deployment: success
echo -e "\n###################################################"
echo "LAMP stack and Laravel are installed."
echo -e "\n###################################################"
echo "Script executed successfully."
```

- After the script runs completely (on the master vm), if you input the IP address of the master vm (192.168.56.10) into a browser and hit enter, the browser will display the homepage of the Laravel app that was cloned from GitHub. This confirms that the script ran successfully and the Laravel app is accessible via the master vm.

![Laravel App landing page display served from web server (Apache2) on Master VM through IP address 192.168.56.10](/assets/media/blog/img-1.png "Laravel App landing page display served from web server (Apache2) on Master VM through IP address 192.168.56.10")

## Ansible, and running the script in the Slave VM.

Once the bash script runs successfully on the master vm the next step is to run the script in the slave vm, using Ansible.

**What is Ansible?**

Ansible is a tool used to manage and set up different computers and servers automatically, without needing to manually type commands or install software on each one individually. It works by letting you write simple instructions that tell your computers what software to install, what settings to use, and how to communicate with each other. This is especially helpful for people who need to handle many computers at once, as it makes the process much faster and reduces the chance of making mistakes.

The simple instructions you write through Ansible to communicate with computers and servers are called Playbooks, also known as Ansible Playbooks. These Ansible Playbooks are data files written in YAML format.

To run the bash script from the master vm on the slave vm, using Ansible, we need to write an Ansible Playbook.

Here’s how I did that:

- First, I created an Ansible Inventory file. Ansible reads this file to know and set the connection mechanism between the master vm and the slave vm. Ansible connects to servers through an SSH connection. For the SSH connection to work, Ansible needs to know the whereabouts (or directory) of the private key with which to connect to the slave vm, that’s what the line below does.
`ansible_ssh_private_key_file: /home/vagrant/.ssh/id_rsa_slavevm`
Note: Ansible Inventory files similar to Ansible Playbooks are written YAML format.

```yaml
all:
  hosts:
    slave:
      ansible_host: 192.168.56.11
      ansible_user: vagrant
      ansible_ssh_private_key_file: /home/vagrant/.ssh/id_rsa_slavevm
```

- The Ansible Playbook, as seen in the code below, which is set to “Deploy LAMP stack/Laravel application and set cron job on Slave node” on the slave vm, runs 6 tasks which are ultimately supposed to facilitate 3 things: transfer the bash script from the master vm to the slave vm, execute the bash script on the slave vm, and set a cronjob to check and log server uptime on the slave vm every 12 am.

```yaml
---
- name: Deploy LAMP stack/Laravel application and set cron job on Slave node
  hosts: slave

  tasks:
    - name: Transfer Master VM bash script to Slave node
      copy:
        src: /home/vagrant/deploy-LAMP-stack.sh
        dest: /home/vagrant/deploy-LAMP-stack.sh
        mode: "0755"

    - name: Transfer Master VM config file to Slave node
      copy:
        src: /home/vagrant/deploy-LAMP-stack.cfg
        dest: /home/vagrant/deploy-LAMP-stack.cfg
        mode: "0755"

    - name: Remove Windows line endings from bash script
      command: sed -i 's/\r$//' deploy-LAMP-stack.sh
      args:
        chdir: /home/vagrant

    - name: Execute Master VM bash script on Slave node
      command: ./deploy-LAMP-stack.sh
      args:
        chdir: /home/vagrant

    - name: Check if the Laravel application is up and running
      uri:
        url: http://192.168.56.11
        return_content: yes
      register: webpage
      until: webpage.status == 200
      retries: 5
      delay: 10

    - name: Set cron job to check server uptime
      cron:
        name: "Check uptime"
        minute: "0"
        hour: "0"
        job: "uptime >> /var/log/uptime.log" 

```

### Transfer Bash Script from Master VM to Slave VM

Even though Vagrant VM provisioning offers a ‘shared folder’ feature which should allow access to the bash script on the slave vm via this path `/vagrant/scripts/deploy-LAMP-stack.sh` , because the assignment instructed me to execute the bash script created in the master vm in the slave vm, my first task in the Ansible Playbook was to transfer the bash script from the master vm to the slave vm.

```yaml
- name: Transfer Master VM bash script to Slave node
      copy:
        src: /home/vagrant/deploy-LAMP-stack.sh
        dest: /home/vagrant/deploy-LAMP-stack.sh
        mode: "0755"
```

Transferring the bash script also meant transferring the config file which is needed to run the bash script.

```yaml
- name: Transfer Master VM config file to Slave node
      copy:
        src: /home/vagrant/deploy-LAMP-stack.cfg
        dest: /home/vagrant/deploy-LAMP-stack.cfg
        mode: "0755"
```

The bash script file was created and edited on my WindowsOS PC, therefore, when the file was copied into a LinuxOS machine it had a problem with ‘line endings’ which is a common Windows-Linux problem. To resolve that, I created another task to remove Windows line endings from the bash script file—essentially, changing the file line endings from CRLF to LF [which is suitable for the Linux File System (LFS)].

```yaml
- name: Remove Windows line endings from bash script
      command: sed -i 's/\r$//' deploy-LAMP-stack.sh
      args:
        chdir: /home/vagrant
```

### Execute Bash Script on Slave VM

Now, the bash script is transferred and configured in the home directory of the vagrant user on slave vm. I wrote a task using the Ansible ‘command’ module to run the bash script file on the slave vm.

```yaml
- name: Execute Master VM bash script on Slave node
      command: ./deploy-LAMP-stack.sh
      args:
        chdir: /home/vagrant
```

To check if the bash script ran successfully, and the Laravel application is up and running on the slave vm, I wrote a task using the Ansible ‘uri’ module to check the web status of the slave vm’s IP address 192.168.56.11 .

```yaml
- name: Check if the Laravel application is up and running
      uri:
        url: http://192.168.56.11
        return_content: yes
      register: webpage
      until: webpage.status == 200
      retries: 5
      delay: 10
```

### Set a Cronjob to Check and Log Server Uptime on the Slave VM Every 12 AM

I wrote a task using the Ansible ‘cron’ module to set a cronjob to check and log server uptime to the path `/var/log/uptime.log` on the slave vm every 12am.

```yaml
- name: Set cron job to check server uptime
      cron:
        name: "Check uptime"
        minute: "0"
        hour: "0"
        job: "uptime >> /var/log/uptime.log"
```

If I’d decided to stop here I’d have already completed the tasks required by my bootcamp and finished my assignment, but I took it a step forward to automate every manual process and fine-tune my work.

## Provisioning for both VMs (Master and Slave)

After creating the bash script, confirming it works, writing Ansible Playbook, executing the bash script and setting a cronjob on slave vm, I provisioned the master and slave vm to automate manual steps and things I did within each of the vms during the entire process of my work. I did this to ensure I reduced the number of manual steps it took to perform the entire process again.

This is what my Vagrantfile finally looked like.

```ruby
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

```

This Vagrantfile can be segmented into three parts. One, the config & provisioning of both vms. Two, the config and provisioning of the master vm. Three, the config & provisioning of the slave vm.

### Config & Provisioning of both VMS (Master & Slave)

```ruby
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
```

- Updated both vm app package repositories using this command
`sudo apt-get update`
- Set ‘needrestart’ feature for scripts when they installed to ‘a’ which means automatically, instead of ‘i’ which means interactive.
- Installed SSH software package on both VMs.

### Config & Provisioning of Master VM

```ruby
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
```

- Copied the bash script and external config file from the Vagrant shared folder to the Vagrant user home directory, set file permissions, and changed the file line endings from CRLF to LF [which is suitable for the Linux File System (LFS)] using the `sed` command.
- Installed and configured Ansible:
    - `sudo mv ansible.cfg ansible.cfg_backup` backed up the initial Ansible config file.
    - `sudo ansible-config init --disabled -t all > ansible.cfg` created a new Ansible config file.
    - `sudo sed -i "s/^;host_key_checking=True/host_key_checking=False/" /etc/ansible/ansible.cfg` accessed Ansible config file and changed ‘host_key_checking’ variable from True to False. I did this so that Ansible doesn’t ask/prompt an interactive question when the Ansible Playbook is run. Because as a general rule of thumb, you do not want an automated script to prompt an interactive question, ensuring it runs noninteractively is the best way to certify that the script will run uninterrupted once set in motion.
- Copied Ansible files (the inventory and playbook file) from the Vagrant shared folder to the Vagrant user home directory.
- `master.vm.provision "shell", path: "scripts/ssh_keygen.sh"` generated ssh key-pair for the master vm through a script called ‘ssh_keygen.sh’. We’ll need this ssh key-pair later to access the slave vm through the master vm.
    - My provisioning code earlier instructed Vagrant to run script ‘ssh_keygen.sh’ on the master vm. This is what the script ‘ssh_keygen.sh’ looks like. Again, this script runs in such a way that is not interactive.
        
        ```bash
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
        ```

### Config & Provisioning of Slave VM

```ruby
# provision slave vm
    slave.vm.provision "shell", inline: <<-SHELL

    # Secure SSH connection
    sudo sed -i "s/^#PermitRootLogin prohibit-password/PermitRootLogin prohibit-password/" /etc/ssh/sshd_config # Turn off password-enabled root ssh login
    sudo sed -i "s/^#PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config # Turn off password-enabled ssh login
    sudo systemctl restart ssh # Restart ssh service to enable config
    SHELL
```

- Secured the SSH server connection on the slave vm in anticipation of a connection from the master vm.
    - `sudo sed -i "s/^#PermitRootLogin prohibit-password/PermitRootLogin prohibit-password/" /etc/ssh/sshd_config` turned off password-enabled root ssh login into the slave vm.
    - `sudo sed -i "s/^#PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config` turned off password-enabled ssh login.
- Restarted the SSH service or daemon to enable the new SSH configurations.

## End of Setup

Congratulations on getting to this point of my how-to guide. Finally, my code, provisioning, scripting, and automation is done. Everything works. I’m in awe. I’m elated. I just created something beautiful that runs.

But don’t take my word that it runs, try it for yourself using the links and techniques I’ll share next: **how to test that this entire setup works on your own PC**.

## HOW TO TEST: Deploy LAMP stack through bash script built on Master VM on Slave VM using Ansible.

I’ve published all my code to GitHub (https://github.com/allwelldotdev/altschool-cloud-sem2-project_exam).

Clone my repo and try this.

**Prerequisites & Dependencies:** You’ll need to have the following software installed on your pc for these tests to work.

- Vagrant
- Oracle VM Virtualbox Manager
- Git Bash (for Windows users).
- Web browser.

**Things To Do:**

1. Open your Git Bash terminal (for Windows users) or Terminal (for MacOS users).
2. Clone my GitHub repo, and change directory into my GitHub project.
3. Apply the command `vagrant up && vagrant ssh master` to fire up both vms (master & slave) taking configurations and provisions instructions from my Vagrantfile.

At this point, let’s recall, in the title, I stated that I reduced to just 2 steps the deployment of a LAMP stack + Laravel app using Bash Shell Scripting, Vagrant, and Ansible.

Here are the two steps:

## Step 1: Copy the Master VM SSH Public Key into the Slave VM ‘authorized_keys’ file.

After firing up both vms using the `vagrant up` command, and logging into the master vm using `vagrant ssh master` , next, we’ll copy the master vm ssh public key into the slave vm ‘authorized_keys’ file.

- Type in the following command into your terminal and hit enter.
`cat ~/.ssh/id_rsa_slavevm.pub`
    
    ![img-2](/assets/media/blog/img-2.png)
    
- Select and copy the ssh public key ‘id_rsa_slavevm.pub’.
- Open another terminal window/process, type the command
`vagrant ssh slave` to bring up the slave vm, then type the following command into your terminal and hit enter.
`vim ~/.ssh/authorized_keys`
    
    ![img-3](/assets/media/blog/img-4.png)
    
- This will open a vim editor on your terminal. Type ‘o’ then paste the public key into the file by pressing ‘Shift + Ins’.
- Close the vim editor by pressing, in this order, ‘Esc’, then ‘:wq’, hit enter. This should save your entry in the file and close the vim editor.

## Step 2: Run the Ansible Playbook.

Once you’ve completed Step 1, the next thing to do is run the Ansible Playbook. Remember, because of our master vm provisioning techniques we have already copied our Ansible Playbook and Inventory file from the Vagrant Shared Folder to our Vagrant user home directory on the master vm.

- Go back to the other terminal where you’d earlier logged into the master vm. Make sure your working directory is the home directory of the Vagrant user. You can confirm by using the command `pwd` . It should return `/home/vagrant` . If it doesn’t, use the command `cd /home/vagrant` and follow on with the next bullet point.
- List the home directory, using the `ls` command, and you should see the ‘ansible’ directory which was provisioned into the vm. Change directory into the ‘ansible’ directory. In the ‘ansible’ directory are two files: inv.yaml (Ansible Inventory file) and plyabook.yaml (Ansible Playbook file). We would use these files to run the Ansible Playbook.
    
    ![img-3](/assets/media/blog/img-3.png)
    
- Run the Ansible Playbook using this command:
`ansible-playbook -i inv.yaml playbook.yaml`

## In Conclusion

Once you run the Ansible Playbook, Ansible, through Python scripts, will execute all the tasks sets in the playbook on the slave vm.

![img-5](/assets/media/blog/img-5.png)

This will complete the assignment, and when you open the slave vm IP address (192.168.56.11) in a browser, you’ll access the landing page of the Laravel App served through the web server (Apache) on the slave vm.

![Laravel App landing page display served from web server (Apache2) on Slave VM through IP address 192.168.56.11](/assets/media/blog/img-6.png "Laravel App landing page display served from web server (Apache2) on Slave VM through IP address 192.168.56.11")

That’s how you deploy a LAMP stack + Laravel App using Bash Shell Scripting, Vagrant, and Ansible with just 2 steps.

Thank you for reading.

Stay healthy. Stay curious.

---

PS. I’ve published this article on [LinkedIn](https://www.linkedin.com/pulse/infrastructure-automation-i-reduced-just-2-steps-lamp-agwu-okoro-rrwsf/?trackingId=txZHdUfoQOqo%2BAA74MfP3w%3D%3D), [Medium](https://medium.com/@allwelldotdev/infrastructure-automation-i-reduced-to-just-2-steps-the-deployment-of-a-lamp-stack-laravel-app-47f24a4e87fe), and [Dev](https://dev.to/allwelldotdev/i-reduced-to-just-2-steps-the-deployment-of-a-lamp-stack-laravel-app-using-bash-shell-scripting-vagrant-and-ansible-24cl). I’d like to ask you to, please give it a like and share so others may benefit from it too. Thank you.

