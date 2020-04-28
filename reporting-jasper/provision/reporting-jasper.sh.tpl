sleep 5
#TODO remove existing jdk if exists
##Install OpenJDK 8
sudo apt-get install -y openjdk-8-jdk
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

##Install postgresql 9.6
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -
sudo apt-get update
sudo apt-get install -y postgresql-9.6

##Install tomcat 9
sudo apt-get install -y tomcat9

##Other dependencies
sudo apt-get install -y unzip
sudo apt-get install -y awscli

##install jasper-server
[ -f ~/jasper-server.zip ] || aws s3 cp s3://openchs/binaries/TIB_js-jrs-cp_7.5.0_bin.zip ~/jasper-server.zip
unzip jasper-server.zip

cd jasperreports-server-cp-7.5.0-bin/buildomatic/
aws s3 cp s3://openchs/binaries/jasper-config/default_master.properties default_master.properties #TODO move this to provision file
sudo mkdir /opt/jasper-config
sudo chown o+rw /opt/jasper-config
export ks=/opt/jasper-config
export ksp=/opt/jasper-config

#-postgres password issue
sudo chmod -R o+rw /usr/share/tomcat9/lib/
sudo chmod -R o+rw /var/lib/tomcat9/webapps/

./js-install-ce.sh minimal

#restart tomcat
sudo service tomcat restart
