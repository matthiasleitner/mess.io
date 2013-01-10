redis = require("redis")
RedisObject = require("./redis_object")

class User extends RedisObject

  @hasMany: ["messages", "devices"]
  @belongsTo: ["application"]
  
  # addDevice: (device, cb) ->
  #   super.client.SADD "devices_for_user|#{@id}", device.id, cb

  # messages: (cb) ->
  #   super.client.SMEMBERS "messages_for_user|#{@id}", cb

  toString: ->
    return "ID: #{@id} - #{@name} - #{@createdAt}"


module.exports = User
