RedisRecord = require("redis-record")

# User model representing a user who has devices registered at the service
#
#
class User extends RedisRecord
  @hasMany:    ["messages", "devices"]
  @belongsTo:  ["application", "channel"]
  @lookUpBy:   ["key"]
  @hasUniqKey: true
  # limit key length which is only used for demo by now
  @uniqKeyLength: 12

module.exports = User