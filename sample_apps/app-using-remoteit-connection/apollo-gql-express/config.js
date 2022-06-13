require("dotenv").config({ path: "./.env" });

const MYSQL_URL = process.env.MYSQL_URL;
const MYSQL_PORT = process.env.MYSQL_PORT;
const MYSQL_USERNAME = process.env.MYSQL_USERNAME;
const MYSQL_PASSWORD = process.env.MYSQL_PASSWORD;
const MYSQL_DB_NAME = process.env.MYSQL_DB_NAME;

const config = {
  MYSQL_URL,
  MYSQL_PORT,
  MYSQL_USERNAME,
  MYSQL_PASSWORD,
  MYSQL_DB_NAME,
};
module.exports = config;
