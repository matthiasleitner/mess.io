RedisRecord = require("redis-record")

class Channel extends RedisRecord

  @belongsTo: ["application"]
  @hasMany: ["messages", "devices", "users"]

module.exports = Channel
