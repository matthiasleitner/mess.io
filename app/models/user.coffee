redis = require("redis")
RedisObject = require("./redis_object")

class User extends RedisObject

  @hasMany: ["messages", "devices"]
  @belongsTo: ["application"]
  
  # addDevice: (device, cb) ->
  #   super.client.SADD "devices_for_user|#{@id}", device.id, cb


module.exports = User
console.log module.exports