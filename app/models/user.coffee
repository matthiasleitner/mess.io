redis = require("redis")
RedisObject = require("./redis_object")

class User extends RedisObject

  @hasMany:    ["messages", "devices"]
  @belongsTo:  ["application"]
  @lookUpBy:   ["key"]
  @hasUniqKey: true

module.exports = User