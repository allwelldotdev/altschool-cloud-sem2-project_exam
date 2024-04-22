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


# -------------------------------------------


# Get user input for variables

# User input for DBNAME - Database Name
read -s -p "Enter the name of the Laravel Database (e.g. lavarel_db) NB. It doesn't have to be the same as the example \"e.g.\" : " DBNAME

# User input for DBNAME - Database Username
echo -e "\n###################################################"
read -s -p "Enter the username of the Laravel Database (e.g. lavarel_user) NB. It doesn't have to be the same as the example \"e.g.\" : " DBUSER

# User input for DBNAME - Database Password
echo -e "\n###################################################"
read -s -p "Enter the password of the Laravel Database (e.g. lavarel_pass) NB. It doesn't have to be the same as the example \"e.g.\" : " DBPASS
echo -e "\n###################################################"


# Ensure no interactive prompt during installation
export DEBIAN_FRONTEND=noninteractive

# Update system
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

# Secure Installation of MySQL
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

echo -e "\n###################################################"
echo "Installing required PHP 8.2 extensions..."
echo -e "\n###################################################"

sudo apt install php8.2-cli php8.2-common php8.2-fpm php8.2-mysql php8.2-zip php8.2-gd php8.2-mbstring php8.2-curl php8.2-xml php8.2-bcmath php8.2-intl php8.2-zip libapache2-mod-php8.2 git unzip -y

# Restart Apache to load new config
sudo systemctl restart apache2

#-----------------------------

# Install PHPMyAdmin
#echo -e "\n###################################################"
#echo "Installing PHPMyAdmin..."
#echo -e "\n###################################################"

#sudo apt install phpmyadmin -y

# Set PHPMyAdmin root password
#echo -e "\n###################################################"
#echo "Set PHPMyAdmin root password..."
#echo -e "\n###################################################"

#sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY '$DBPASS';"

# Configure PHPMyAdmin with Apache
#echo -e "\n###################################################"
#echo "Configuring PHPMyAdmin with Apache..."
#echo -e "\n###################################################"

#sudo echo 'Include /etc/phpmyadmin/apache.conf' >> /etc/apache2/apache2.conf

# Restart Apache web server
#sudo systemctl restart apache2

# Install Composer
echo -e "\n###################################################"
echo "Installing Composer..."
echo -e "\n###################################################"

#sudo apt install composer -y

#wget https://raw.githubusercontent.com/composer/getcomposer.org/9f6b66dc3cd73688bc214683001a6b2320379393/web/installer -O - -q | php -- --quiet

# php composer-setup.php --install-dir=bin --filename=composer --quiet

curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer --quiet

#sudo mv composer.phar /usr/local/bin/composer

#-----------------------------

# Clone Laravel project
echo -e "\n###################################################"
echo "Cloning Laravel from GitHub..."
echo -e "\n###################################################"

cd /var/www/html
sudo git clone https://github.com/laravel/laravel.git
cd laravel

# Installing Composer dependencies
echo -e "\n###################################################"
echo "Installing Composer dependencies..."
echo -e "\n###################################################"

# composer create-project --prefer-dist laravel/laravel /var/www/html/laravel

#composer self-update --no-interaction --prefer-dist --optimize-autoloader --working-dir=/var/www/html/laravel

sudo composer install --no-interaction --prefer-dist --optimize-autoloader --working-dir=/var/www/html/laravel

#sudo composer update --no-interaction --prefer-dist --optimize-autoloader --working-dir=/var/www/html/laravel

# Set permissions for Laravel
echo -e "\n###################################################"
echo "Setting permissions for Laravel..."
echo -e "\n###################################################"

sudo chown -R www-data:www-data /var/www/html/laravel
#sudo find /var/www/html/laravel -type d -exec chmod 755 {} \;
#sudo find /var/www/html/laravel -type f -exec chmod 644 {} \;

# Setup Database
echo -e "\n###################################################"
echo "Setting up MySQL database..."
echo -e "\n###################################################"

sudo mysql -u root -p$DBPASS <<MYSQL_SCRIPT
CREATE DATABASE $DBNAME;
CREATE USER '$DBUSER'@'localhost' IDENTIFIED BY '$DBPASS';
GRANT ALL PRIVILEGES ON $DBNAME.* TO '$DBUSER'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

# Set proper permissions for storage and bootstrap cache directories
echo -e "\n###################################################"
echo "Setting permissions for storage and bootstrap cache directories..."
echo -e "\n###################################################"

sudo chown -R www-data:www-data /var/www/html/laravel
#sudo chown -R www-data:www-data /var/www/html/laravel/storage /var/www/html/laravel/bootstrap/cache
sudo chmod -R 775 /var/www/html/laravel/storage /var/www/html/laravel/bootstrap/cache

# Setup Laravel environment file
echo -e "\n###################################################"
echo "Configuring Laravel environment..."
echo -e "\n###################################################"

sudo cp .env.example .env
#sudo chown www-data:www-data .env
#sudo chmod 775 .env

sudo sed -i "s/DB_CONNECTION=sqlite/DB_CONNECTION=mysql/" .env
sudo sed -i 's/^# DB_HOST=127.0.0.1/DB_HOST=127.0.0.1/' .env
sudo sed -i 's/^# DB_PORT=3306/DB_PORT=3306/' .env
sudo sed -i "s/^# DB_DATABASE=laravel/DB_DATABASE=$DBNAME/" .env
sudo sed -i "s/^# DB_USERNAME=root/DB_USERNAME=$DBUSER/" .env
sudo sed -i "s/^# DB_PASSWORD=/DB_PASSWORD=$DBPASS/" .env

php artisan migrate

# Clear and cache configurations
echo "Clearing and caching configurations..."
php artisan config:clear
php artisan cache:clear
#php artisan config:cache

#sudo chown -R www-data:www-data /var/www/html/laravel/
#sudo chmod -R 775 /var/www/html/laravel/

# Generate Laravel key
echo -e "\n###################################################"
echo "Generating Laravel key..."
echo -e "\n###################################################"

sudo php artisan key:generate
#sudo php /var/www/html/laravel/artisan key:generate


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

echo -e "\n###################################################"
echo "LAMP stack and Laravel are installed."
echo -e "\n###################################################"









echo "Script executed successfully."
