set -e
export MB_PASSWORD_COMPLEXITY=strong
export MB_PASSWORD_LENGTH=12
export MB_JETTY_PORT=3000
export MB_DB_TYPE=postgres
export MB_DB_DBNAME=${db_name}
export MB_DB_PORT=${db_port}
export MB_DB_USER=${db_user}
export MB_DB_PASS=${db_password}
export MB_DB_HOST=${db_host}

#remove java1.7 if present
rpm -qa | grep -qw java-1.7.0-openjdk && sudo yum remove -y java-1.7.0-openjdk java-1.7.0-openjdk-devel

#install java1.8, lsof, metabase if absent
rpm -qa | grep -qw java-1.8.0-openjdk-devel || sudo yum install -y java-1.8.0-openjdk-devel
rpm -qa | grep -qw lsof || sudo yum install -y lsof
[ -f ~/metabase.jar ] || curl -L http://downloads.metabase.com/${metabase_version}/metabase.jar > ~/metabase.jar

#kill if running
lsof -t -i:3000 && kill -9 $(lsof -t -i:3000)
sleep 5
#nohup java -jar ~/metabase.jar >> ~/metabase.log 2>&1 &
nohup java -Dlog4j.configurationFile=file:log4j2.xml -jar metabase.jar >> metabase-startup.log 2>&1 &
sleep 20