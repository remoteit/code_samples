const Sequelize = require("sequelize");
const config = require("./config");
console.log(config);
var db = {};

const sequelize = new Sequelize(
  "graphql_express_example",
  config.MYSQL_USERNAME,
  "weaved1234",
  {
    host: "google-cloud-mysql-mysql.at.remote.it",
    port: 33030,
    dialect: "mysql",
    define: {
      freezeTableName: true,
    },
    pool: {
      max: 5,
      min: 0,
      acquire: 30000,
      idle: 10000,
    },
  }
);

let models = [
  require("./src/models/priorities.js"),
  require("./src/models/tickets.js"),
  require("./src/models/status.js"),
  require("./src/models/users.js"),
];

// Initialize models
models.forEach((model) => {
  const seqModel = model(sequelize, Sequelize);
  db[seqModel.name] = seqModel;
});

// Apply associations
Object.keys(db).forEach((key) => {
  if ("associate" in db[key]) {
    db[key].associate(db);
  }
});

db.sequelize = sequelize;
db.Sequelize = Sequelize;

module.exports = db;
