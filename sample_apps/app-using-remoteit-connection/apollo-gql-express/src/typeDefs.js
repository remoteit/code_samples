const { gql } = require("apollo-server-express");
const db = require("../database");

const typeDefs = gql`
  type Query {
    priorities: [Priority]
    priority(id: ID!): Priority
    tickets: [Ticket]
    ticket(id: ID!): Ticket
    allStatus: [Status]
    status(id: ID!): Status
    users: [User]
    user(id: ID!): User
  }

  type Priority {
    id: ID!
    slug: String
    name: String
  }

  type Ticket {
    id: ID!
    subject: String
    priority_id: Int
    priority: Priority
    status_id: Int
    status: Status
    user_id: Int
    user: User
    assigned_to_user_id: Int
    assigned_to_user: User
  }

  type Status {
    id: ID!
    slug: String
    name: String
  }

  type User {
    id: ID!
    email: String
    name: String
  }
`;

module.exports = typeDefs;
