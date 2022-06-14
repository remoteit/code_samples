const Sequelize = require("sequelize");
const config = require("./config");
const cKey = "raw-loader!~/PemKeys/DigiCertGlobalRootCA.crt.pem";

var db = {};

const sequelize = new Sequelize(
  config.DB_NAME,
  config.DB_USERNAME,
  config.DB_PASSWORD,
  {
    host: config.DB_URL,
    port: config.DB_PORT,
    dialect: config.DB_DIALECT,
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
