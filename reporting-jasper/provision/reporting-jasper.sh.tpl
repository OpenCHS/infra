##Install OpenJDK 8
sudo apt install -y openjdk-8-jdk
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

##Install postgresql 9.6
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -
sudo apt update
sudo apt install -y postgresql-9.6

##Install tomcat 9
sudo apt install -y tomcat9

##Other dependencies
sudo apt install -y unzip
sudo apt install -y awscli

##install jasper-server
[ -f ~/jasper-server.zip ] || aws s3 cp s3://openchs/binaries/TIB_js-jrs-cp_7.5.0_bin.zip ~/jasper-server.zip
unzip jasper-server.zip

aws s3 cp s3://openchs/binaries/jasper-config/default_master.properties ~/jasperreports-server-cp-7.5.0-bin/buildomatic/
~/jasperreports-server-cp-7.5.0-bin/buildomatic/js-install-ce.sh minimal

#set java.awt.headless=true

#start jasper-server
