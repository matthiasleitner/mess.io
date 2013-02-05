RedisObject = require("./redis_object")
User = require("./user")

class Device extends RedisObject
  @belongsTo: ["user", "application"]
  @lookUpBy: ["key", "webSocketToken"]
  @hasUniqKey: true


  supportedChannels: ->
    channels = []
    channels.push "apns"        if @get "apnsToken"
    channels.push "gcm"         if @get "gcmToken"
    channels.push "webSocket"   if @get "webSocketToken"
    return channels

  supportsChannel: (channel) ->
    @supportedChannels().indexOf(channel) >= 0

  supportsChannelCount: ->
    @supportedChannels().length

  removeChannel: (channel) ->
    if @supportsChannelCount() > 1
      @set "#{channel}Token", null
      @save()
    else
      @delete (err, reply) ->
        console.log "removed device with no associated channels"

  @create: (obj, cb) ->
    user = 
      id: obj.userId
      ip: obj.ip
    User.findOrCreate user, (err, reply) =>
      obj.userId = user.id unless obj.userId

      console.log this.name
      new this(obj).save(cb)

module.exports = Device
