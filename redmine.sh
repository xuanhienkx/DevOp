#!/bin/bash
redmine_dbname='redmine'
redmine_dbpassword='das@123456'
# update & upgrade  
sudo apt-get update && sudo apt-get upgrade -y

# install required packages
echo "Install Appche"
sudo apt install -y apache2 ruby ruby-dev build-essential libapache2-mod-passenger libmysqlclient-dev

# if you want to install mysql server locally 
echo "Install mariadb-server mariadb-client"
sudo apt install mariadb-server mariadb-client -y
sudo systemctl start mariadb
sudo systemctl enable mariadb
# change passsowrd root
echo "redmine_dbname  $redmine_dbname"
echo "redmine_dbpassword  $redmine_dbpassword"
sleep 5

echo "change passsowrd root"
sudo mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY  '$redmine_dbpassword';"
sleep 5
#Create a database and create a user for redmine. Example for localhost installation below:
sudo mysql -u root -p$redmine_dbpassword -e "CREATE DATABASE $redmine_dbname CHARACTER SET utf8mb4;" 
sudo mysql -u root -p$redmine_dbpassword -e "GRANT ALL PRIVILEGES ON $redmine_dbname.* TO '$redmine_dbname'@'%' IDENTIFIED BY '$redmine_dbpassword';"
sudo mysql -u root -p$redmine_dbpassword -e "FLUSH PRIVILEGES;" 
 
#download new redmine and theme PurpleMine2
cd ~
wget https://www.redmine.org/releases/redmine-5.0.5.tar.gz
wget https://github.com/mrliptontea/PurpleMine2/archive/master.zip

echo "check file"
ls -lsa ~
sleep 5
#unzip and ungz on /opt
cd /opt/
sudo tar -xvzf ~/redmine-5.0.5.tar.gz
sudo ln -s redmine-5.0.5 redmine 
sudo unzip ~/master.zip
sudo mv PurpleMine2-master/ redmine/public/themes/PurpleMine2
# copy the example file
cd /opt/redmine
cp config/database.yml.example config/database.yml

#change confile db

sleep 5
sed -i -e "/production:/{n;/mysql2/{n;s/database:.*/database: ${redmine_dbname}/;};}"  config/database.yml
sed -i -e "/production:/{n;/mysql2/{n;n;n;s/username:.*/username: ${redmine_dbname}/;};}"  config/database.yml 
sed -i -e "/production:/{n;/mysql2/{n;n;n;n;s/password:.*/password: \"${redmine_dbpassword}\"/;};}"  config/database.yml 

sudo sed -i 's/127.0.0.1/0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf
sudo ufw allow 3306/tcp
sudo systemctl restart mariadb
# install bundler
sudo gem install bundler

# install redmine bundle (give sudo password when prompted)
sudo bundle install

# generate secret token
bundle exec rake generate_secret_token
sleep 5
# migrate database
RAILS_ENV=production bundle exec rake db:migrate
sleep 5
# load default data
RAILS_ENV=production bundle exec rake redmine:load_default_data 
sleep 5
#sudo cat <<EOF > /etc/apache2/sites-available/redmine.conf
sudo cat << EOF > /etc/apache2/sites-available/redmine.conf
# <VirtualHost *:80>
#     ServerName test-redmine.dag.vn
#     Redirect / https://test-redmine.dag.vn
# </VirtualHost>
<VirtualHost *:80>
    ServerName test-redmine.dag.vn
    #RailsEvn production
    RailsEnv production
#   DocumentRoot /var/www/your_domain_or_ip
    DocumentRoot /opt/redmine/public
    <Directory "/opt/redmine/public">
            Allow from all
            Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/redmine_error.log
    CustomLog ${APACHE_LOG_DIR}/redmine_access.log combined

#    SSLEngine on
#    SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
#    SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key
</VirtualHost> 
EOF

#Before we can use any SSL certificates, we first have to enable mod_ssl, an Apache module that provides support for SSL encryption.
#sudo a2enmod ssl

#We can create the SSL key and certificate files with the openssl command:
#sudo openssl req -x509 -nodes -days 9999 -newkey rsa:2048 -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt
# disable default apache sites
sudo a2dissite 000-default.conf

# enable redmine
sudo a2ensite redmine.conf
# reload restart
sudo systemctl restart apache2 
# reload apache
sudo systemctl reload apache2

# allow rule on fw for apache
sudo ufw allow "Apache Full"

 



 



