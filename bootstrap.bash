#!/usr/bin/env bash
 
#
# Vagrant nginx & php-fpm
# Vagrant basic bootstrap.sh file configuration for getting a ready to use dev solution
# 
# Ivan Zinovyev <vanyazin@gmail.com>
# 
# (The "ubuntu/trusty64" box was used and tested)
#
 
apt-get update
#if ! [ -L /var/www ]; then
#    rm -rf /var/www
#    ln -fs /vagrant /var/www
#fi
 
# Install nginx
apt-get install -y nginx
 
# Install mysql
apt-get install -y debconf-utils
debconf-set-selections <<< "mysql-server mysql-server/root_password password 13"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password 13"
apt-get install -y mysql-server mysql-client
 
# Install php-fpm
apt-get install -y php5-cli php5-common php5-mysql php5-gd php5-fpm php5-cgi php5-fpm php-pear php5-mcrypt
apt-get -f install
 
# Stop servers
service nginx stop
service php5-fpm stop
 
# php.ini
if [ ! -f /etc/php5/fpm/php.ini.bkp ]; then
    cp /etc/php5/fpm/php.ini /etc/php5/fpm/php.ini.bkp
else
    rm /etc/php5/fpm/php.ini
    cp /etc/php5/fpm/php.ini.bkp /etc/php5/fpm/php.ini
fi
sed -i.bak 's/^;cgi.fix_pathinfo.*$/cgi.fix_pathinfo = 0/g' /etc/php5/fpm/php.ini
 
# www.conf
if [ ! -f /etc/php5/fpm/pool.d/www.conf.bkp ]; then
    cp /etc/php5/fpm/pool.d/www.conf /etc/php5/fpm/pool.d/www.conf.bkp
else
    rm /etc/php5/fpm/pool.d/www.conf
    cp /etc/php5/fpm/pool.d/www.conf.bkp /etc/php5/fpm/pool.d/www.conf
fi
sed -i.bak 's/^;security.limit_extensions.*$/security.limit_extensions = .php .php3 .php4 .php5/g' /etc/php5/fpm/pool.d/www.conf
sed -i.bak 's/^;listen\s.*$/listen = \/var\/run\/php5-fpm.sock/g' /etc/php5/fpm/pool.d/www.conf
sed -i.bak 's/^listen.owner.*$/listen.owner = www-data/g' /etc/php5/fpm/pool.d/www.conf
sed -i.bak 's/^listen.group.*$/listen.group = www-data/g' /etc/php5/fpm/pool.d/www.conf
sed -i.bak 's/^;listen.mode.*$/listen.mode = 0660/g' /etc/php5/fpm/pool.d/www.conf
 
service php5-fpm restart
 
# Nginx
if [ ! -f /etc/nginx/sites-available/dev.vm ]; then
    touch /etc/nginx/sites-available/dev.vm
fi
 
if [ -f /etc/nginx/sites-enabled/default ]; then
    rm /etc/nginx/sites-enabled/default
fi
 
if [ ! -f /etc/nginx/sites-enabled/dev.vm ]; then
    ln -s /etc/nginx/sites-available/vagrant /etc/nginx/sites-enabled/dev.vm
fi
 
# Configure host
cat << 'EOF' > /etc/nginx/sites-available/dev.vm
server
{
    listen  80;
    root /dev.vm;
    index index.php index.html index.htm;
    server_name dev.vm
    location "/"
    {
        index index.php index.html index.htm;
        try_files $uri $uri/ =404;
    }
 
    location ~ \.php$
    {
        include /etc/nginx/fastcgi_params;
        fastcgi_pass unix:/var/run/php5-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME /vagrant$fastcgi_script_name;
    }
}
EOF
 
# Restart servers
service nginx restart
service php5-fpm restart
