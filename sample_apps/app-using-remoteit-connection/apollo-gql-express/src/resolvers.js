const db = require("../database");

const resolvers = {
  Query: {
    priorities: async () => db.priorities.findAll(),
    priority: async (obj, args, context, info) =>
      db.priorities.findByPk(args.id),
    tickets: async () => db.tickets.findAll(),
    ticket: async (obj, args, context, info) => db.tickets.findByPk(args.id),
    allStatus: async () => db.status.findAll(),
    status: async (obj, args, context, info) => db.status.findByPk(args.id),
    users: async () => db.users.findAll(),
    user: async (obj, args, context, info) => db.users.findByPk(args.id),
  },
  Ticket: {
    user: async (obj, args, context, info) => db.users.findByPk(obj.user_id),
    priority: async (obj, args, context, info) =>
      db.priorities.findByPk(obj.priority_id),
    status: async (obj, args, context, info) =>
      db.status.findByPk(obj.status_id),
    assigned_to_user: async (obj, args, context, info) =>
      db.users.findByPk(obj.assigned_to_user_id),
  },
};

module.exports = resolvers;
