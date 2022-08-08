require("dotenv").config({ path: "./.env" });

const DB_URL = process.env.MYSQL_URL;
const DB_PORT = process.env.MYSQL_PORT;
const DB_USERNAME = process.env.MYSQL_USERNAME;
const DB_PASSWORD = process.env.MYSQL_PASSWORD;
const DB_NAME = process.env.MYSQL_DB_NAME;
const DB_DIALECT = "mysql";
/*
const DB_URL = process.env.AZURE_MYSQL_URL;
const DB_PORT = process.env.AZURE_MYSQL_PORT;
const DB_USERNAME = process.env.AZURE_MYSQL_USERNAME;
const DB_PASSWORD = process.env.AZURE_MYSQL_PASSWORD;
const DB_NAME = process.env.AZURE_MYSQL_DB_NAME;
const DB_DIALECT = "mysql";


const DB_URL = process.env.GCP_POSTGRES_URL;
const DB_PORT = process.env.GCP_POSTGRES_PORT;
const DB_USERNAME = process.env.GCP_POSTGRES_USERNAME;
const DB_PASSWORD = process.env.GCP_POSTGRES_PASSWORD;
const DB_NAME = process.env.GCPPOSTGRES_DB_NAME;
const DB_DIALECT = "postgres";
*/
const config = {
  DB_URL,
  DB_PORT,
  DB_USERNAME,
  DB_PASSWORD,
  DB_NAME,
  DB_DIALECT,
};
module.exports = config;
