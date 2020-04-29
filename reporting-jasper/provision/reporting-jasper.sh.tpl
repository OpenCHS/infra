#sleep 5
sudo apt-get update
sudo apt-get upgrade -y

##Install OpenJDK 8
sudo apt-get install -y openjdk-8-jdk
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

##Add postgres apt source and update apt
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -

sudo apt-get update

##Install postgresql 9.6
sudo apt-get install -y postgresql-9.6

##Configure postgres auth and restart
#disabling for now as jasper expects password authentication.
#sudo -u postgres -i -- sh -c 'cp /etc/postgresql/9.6/main/pg_hba.conf /etc/postgresql/9.6/main/pg_hba.conf.default'
#sudo -u postgres sed -i  '/^local   all             postgres                                peer/ s/peer/trust/' /etc/postgresql/9.6/main/pg_hba.conf
#echo "local   all             postgres                                trust" | sudo -u postgres tee -a /etc/postgresql/9.6/main/pg_hba.conf
#echo "host    all             all             127.0.0.1/32            trust" | sudo -u postgres tee -a /etc/postgresql/9.6/main/pg_hba.conf

sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'postgres';"
sudo service postgresql restart

##Install tomcat 9
sudo apt-get install -y tomcat9

##Install other dependencies
sudo apt-get install -y unzip
sudo apt-get install -y awscli

##Install jasper-server
[ -f ~/jasper-server.zip ] || aws s3 cp s3://openchs/binaries/TIB_js-jrs-cp_7.5.0_bin.zip ~/jasper-server.zip
unzip jasper-server.zip

cd jasperreports-server-cp-7.5.0-bin/buildomatic/
aws s3 cp s3://openchs/binaries/jasper-config/default_master.properties default_master.properties
sudo mkdir /opt/jasper-config
sudo chmod o+rw /opt/jasper-config
export ks=/opt/jasper-config
export ksp=/opt/jasper-config

sudo chmod -R o+rw /usr/share/tomcat9/lib/
sudo chmod -R o+rw /var/lib/tomcat9/webapps/

./js-install-ce.sh minimal

chmod o+r /opt/jasper-config/.*

#Restart tomcat
sudo service tomcat9 restart
