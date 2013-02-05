redis = require("redis")
RedisObject = require("./redis_object")

# User model representing a user who has devices registered at the service
#
#
class User extends RedisObject

  @hasMany:    ["messages", "devices"]
  @belongsTo:  ["application"]
  @lookUpBy:   ["key"]
  @hasUniqKey: true

module.exports = User