apollo-gql-express is a sample graphql API project which you can run locally and use a remote.it connection for your database connection.
This project is using Sequelize to manage transactions and relations. Sequelize is a promise-based Node.js ORM tool for Postgres, MySQL, MariaDB, SQLite, Microsoft SQL Server, Amazon Redshift and Snowflake’s Data Cloud. It features solid transaction support, relations, eager and lazy loading, read replication and more.
The default example is using MySQL, but you can use the Sequelize documentation to modify the project to use a different database.

To get started:

1. Fetch the code at apollo-gql-express.
2. Make sure you have Node >=v16.15.1 https://nodejs.org/en/download/
3. Ensure you have NPM >=8.12.1 If you installed Node above, you will have NPM
4. In console at the root of the apollo-gql-express project run `npm install`

Next you will set up the database - you can skip these steps if using a shared database from remote.it
Set up remoteit access to your database in the cloud (This will work for AWS, GCP and Azure) - You can skip this step if you are using a shared playground database

1. Create user and database
2. Populate data with mysql.sql (note the sql might need to be modified to match syntax for your database)
3. Setup a remote.it jump service to your database.

Use the remote.it connection and run the server

1. Open the remote.it desktop and make a connection to the database service.
2. Make a copy of sample.env and rename to .env updating the values for the variables based on your remote.it connection and db information
3. Execute `npm run dev`

The url for the graphQL server will be http://localhost:4000/graphql
Note this is a very simple version of a graphQL API. There is no authentication to use the API. It is a proof of concept application to show using a remote.it connection to a cloud database.
