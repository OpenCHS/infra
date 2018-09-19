//Needed when you want to migrate users retrieved from Cognito and you want to add them to the server
let cognitoUserResponse = require("../cognito-users.json");

function getCustomAttributeValue(cognitoUser, attributeName) {
    let attribute = cognitoUser["Attributes"].find(function (attribute) {
        return attribute["Name"] === ("custom:" + attributeName);
    });
    return attribute["Value"];
}

function mapToServerContract(cognitoJSON) {
    return cognitoJSON["Users"].map(function (cognitoUser) {
        return {
            "name": cognitoUser["Username"],
            "organisationId": Number(getCustomAttributeValue(cognitoUser, "organisationId")),
            "catchmentId": Number(getCustomAttributeValue(cognitoUser, "catchmentId")),
            "orgAdmin": getCustomAttributeValue(cognitoUser, "isOrganisationAdmin") === "true",
            "admin": getCustomAttributeValue(cognitoUser, "isAdmin") === "true"
        };
    });
}

let output = mapToServerContract(cognitoUserResponse);
console.log(JSON.stringify(output));