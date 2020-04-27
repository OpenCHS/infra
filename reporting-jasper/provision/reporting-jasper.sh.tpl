set -e
#remove java1.7 if present
rpm -qa | grep -qw java-1.7.0-openjdk && sudo yum remove -y java-1.7.0-openjdk java-1.7.0-openjdk-devel

#install java1.8, lsof if absent
rpm -qa | grep -qw java-1.8.0-openjdk-devel || sudo yum install -y java-1.8.0-openjdk-devel
rpm -qa | grep -qw lsof || sudo yum install -y lsof

#install jasper-server if absent
[ -f ~/jasper-server.run ] || aws s3 cp s3://<bucket>/TIB_js-jrs-cp_7.5.0_linux_x86_64.run ~/jasper-server.run
chmod a+x ~/jasper-server.run
#TODO figure out unattended install for jasper-server community edition
#https://community.jaspersoft.com/wiki/unattended-mode-installation
#OR use war file package (TIB_js-jrs-cp_x.y.z_bin.zip) https://community.jaspersoft.com/documentation/jasperreports-server-pro-install-guide/v56/installing-war-file-using-js-install

#start jasper-server
#set java.awt.headless=true
#execute <installed_path>/ctlscript.sh start