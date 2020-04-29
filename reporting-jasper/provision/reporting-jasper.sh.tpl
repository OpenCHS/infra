#sleep 5
sudo apt-get update
sudo apt-get upgrade -y

##Install OpenJDK 8
sudo apt-get install -y openjdk-8-jdk
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

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
