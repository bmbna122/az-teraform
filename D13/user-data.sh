#!/bin/bash
set -e
apt-get update -y
apt-get install -y apache2 php php-curl libapache2-mod-php php-mysql jq

systemctl enable apache2
systemctl restart apache2

usermod -a -G www-data azureuser

mkdir -p /var/www/html
chown -R azureuser:www-data /var/www
chmod 2755 /var/www
find /var/www -type d -exec chmod 2755 {} \;
find /var/www -type f -exec chmod 0644 {} \;
cd /var/www/html
curl -s -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance?api-version=2021-02-01" | jq > index.html
sed -i '1i<pre>' index.html
sed -i '$a</pre>' index.html
curl https://raw.githubusercontent.com/Azure/vm-scale-sets/master/terraform/terraform-tutorial/app/index.php -O