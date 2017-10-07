input { stdin { } }
output {
elasticsearch { hosts => ["${elasticsearch_host}"] }
stdout { codec => rubydebug }
}