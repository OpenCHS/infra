export OPENCHS_SERVER=localhost
export OPENCHS_SERVER_PORT=${server_port}
export OPENCHS_SERVER_OPTS="-Xmx250m -XX:ErrorFile=/var/log/openchs/jvm.log"
export OPENCHS_DATABASE_HOST=${database_host}
export OPENCHS_DATABASE_USER=${database_user}
export OPENCHS_DATABASE_PASSWORD=${database_password}
export OPENCHS_DATABASE_URL="jdbc:postgresql://${database_host}:${database_port}/${database_name}"