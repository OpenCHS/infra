//NOT USED
let users = require("./users");
const { spawnSync } = require("child_process");

let cognitoUsers = users.map(function (user) {
    return {
        'Username': user["name"],
        'UserPoolId': process.argv[2],
        'ValidationData': [],
        'UserAttributes': [
            {'Name': 'email', 'Value': user["email"]},
            {'Name': 'phone_number', 'Value': user["phoneNumber"]},
            {'Name': 'custom:organisationName', 'Value': user["orgName"]},
            {'Name': 'custom:isAdmin', 'Value': `${user["admin"]}`},
            {'Name': 'custom:isOrganisationAdmin', 'Value': `${user["orgAdmin"]}`},
            {'Name': 'custom:userUUID', 'Value': user["uuid"]}
        ],
        'ForceAliasCreation': true,
        'TemporaryPassword': user["password"],
        'DesiredDeliveryMediums': ['SMS', 'EMAIL']
    };
});


cognitoUsers.forEach(function (cognitoUser) {
    let aws = spawnSync('aws', ["cognito-idp", "admin-create-user", "--cli-input-json", cognitoUser]);
    console.log(aws.output);
    // aws.stdout.on('data', (data) => {
    //     console.log(`stdout: ${data}`);
    // });
    // aws.stderr.on('data', (data) => {
    //     console.log(`stderr: ${data}`);
    // });
    // aws.on('close', (code) => {
    //     console.log(`child process exited with code ${code}`);
    // });
});

