module.exports = function (sequelize, DataTypes) {
  return sequelize.define(
    "status",
    {
      id: {
        type: DataTypes.INTEGER(10).UNSIGNED,
        allowNull: false,
        primaryKey: true,
        autoIncrement: true,
      },
      slug: {
        type: DataTypes.STRING(64),
        allowNull: false,
      },
      name: {
        type: DataTypes.STRING(256),
        allowNull: false,
      },
    },
    {
      tableName: "status",
      timestamps: false,
    }
  );
};
