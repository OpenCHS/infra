//Needed when you want to take common users format and create Server format
let users = require("./users");

function mapToServerContract(users) {
    return users.map(function (user) {
        user["password"] = undefined;
        return user;
    });
}

let output = mapToServerContract(users);
console.log(JSON.stringify(output));