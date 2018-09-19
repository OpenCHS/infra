import sys
import subprocess
import json

user_pool_id = sys.argv[1]

def json_input(user):
    return {
        'Username': user["name"],
        'UserPoolId': user_pool_id,
        'ValidationData': [],
        'UserAttributes': [
            {'Name': 'email', 'Value': user["email"]},
            {'Name': 'phone_number', 'Value': user["phoneNumber"]},
            {'Name': 'custom:organisationName', 'Value': user["orgName"]},
            {'Name': 'custom:isAdmin', 'Value': "true" if user["admin"] else "false"},
            {'Name': 'custom:isOrganisationAdmin', 'Value': "true" if user["orgAdmin"] else "false"},
            {'Name': 'custom:userUUID', 'Value': user["uuid"]}
        ],
        'ForceAliasCreation': True,
        'TemporaryPassword': user["password"],
        'DesiredDeliveryMediums': ['SMS', 'EMAIL']
    }

def create_user(user):
    user_json = json_input(user)
    print subprocess.check_output(
        ["aws", "cognito-idp", "admin-create-user", "--cli-input-json", json.dumps(user_json)])

users = json.load(open('./users.json'))
map(create_user, users)