#!/bin/bash

users=$1
poolid=$2
while IFS= read -r username
do
  aws cognito-idp admin-disable-user --username "$username" --user-pool-id "$poolid"
done < "$users"
