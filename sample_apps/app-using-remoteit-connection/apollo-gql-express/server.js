const express = require("express");
const bodyParser = require("body-parser");
const { ApolloServer } = require("apollo-server-express");
const cors = require("cors");

const db = require("./database");
const typeDefs = require("./src/typeDefs");
const resolvers = require("./src/resolvers");

async function startserver() {
  const app = express();
  app.use(bodyParser.json());
  app.use(bodyParser.urlencoded({ extended: true }));
  app.use(cors());
  await db.sequelize.authenticate();
  const apolloServer = new ApolloServer({
    typeDefs,
    resolvers,
  });

  await apolloServer.start();
  apolloServer.applyMiddleware({ app: app });

  app.use((req, res) => {
    res.send("Hello from apollo express server");
  });
  app.listen(4000, () => console.log("Server is running on port 4000"));
}
startserver();
