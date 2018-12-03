import sys
import subprocess
import json

user_pool_id = sys.argv[1]
profile_name = sys.argv[2] if len(sys.argv) > 2 else 'default'

def json_input(user):
    return {
        'Username': user["name"],
        'UserPoolId': user_pool_id,
        'ValidationData': [],
        'UserAttributes': [
            {'Name': 'email', 'Value': user["email"]},
            {'Name': 'phone_number', 'Value': user["phoneNumber"]},
            {'Name': 'custom:userUUID', 'Value': user["uuid"]}
        ],
        'ForceAliasCreation': True,
        'TemporaryPassword': user["password"],
        'DesiredDeliveryMediums': ['SMS', 'EMAIL']
    }

def create_user(user):
    user_json = json_input(user)
    print user_json
    try:
        print subprocess.check_output(
            ["aws", "--profile", profile_name, "cognito-idp", "admin-create-user", "--cli-input-json", json.dumps(user_json)])
    except Exception as e:
        print e, '\n'

users = json.load(open('./users.json'))
map(create_user, users)