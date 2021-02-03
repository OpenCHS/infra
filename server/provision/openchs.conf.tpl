export OPENCHS_SERVER=localhost
export OPENCHS_SERVER_PORT=${server_port}
export OPENCHS_SERVER_OPTS="-Dlogging.file=/var/log/openchs/chs.log -Dlogging.path=/var/log/openchs/ -Dlogging.file.max-size=5mb -Xmx250m -XX:ErrorFile=/var/log/openchs/jvm.log"
export OPENCHS_DATABASE_HOST=${database_host}
export OPENCHS_DATABASE_USER=${database_user}
export OPENCHS_DATABASE_PASSWORD=${database_password}
export OPENCHS_DATABASE_URL="jdbc:postgresql://${database_host}:${database_port}/${database_name}"
export OPENCHS_USER_POOL=${user_pool_id}
export OPENCHS_CLIENT_ID=${client_id}
export OPENCHS_MODE=live
export OPENCHS_SERVER_BUGSNAG_API_KEY=${bugsnag_api_key}
export OPENCHS_BUGSNAG_RELEASE_STAGE=${environment}
export OPENCHS_BUCKET_NAME=${bucket_name}
export OPENCHS_IAM_USER=${server_iam_user}
export OPENCHS_IAM_USER_ACCESS_KEY=${iam_access_key}
export OPENCHS_IAM_USER_SECRET_ACCESS_KEY=${iam_secret_access_key}
export OPENCHS_STATIC_PATH=/opt/openchs/static/
export OPENCHS_MSG91_AUTHKEY_KEY={msg91_authkey_key}
