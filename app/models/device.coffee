RedisRecord = require("redis-record")
User = require("./user")

# Device model representing a device which is connected to the service
#
#
class Device extends RedisRecord
  @belongsTo: ["user", "application"]
  @lookUpBy: ["key", "webSocketToken"]
  @hasUniqKey: true


  # Returns a list of supported channels
  #
  #
  supportedChannels: ->
    channels = []
    channels.push "apns"        if @get "apnsToken"
    channels.push "gcm"         if @get "gcmToken"
    channels.push "webSocket"   if @get "webSocketToken"
    return channels

  # Check if channel with given identifier is supported by the device
  #
  #
  supportsChannel: (channel) ->
    @supportedChannels().indexOf(channel) >= 0

  # Get number of supported channels
  #
  #
  supportsChannelCount: ->
    @supportedChannels().length

  # Remove channel with given name by removinf its key
  #
  #
  removeChannel: (channel) ->
    if @supportsChannelCount() > 1
      # remove token/id for channel
      @set "#{channel}Token", null
      @save()
    else
      @delete (err, reply) ->
        console.log "removed device with no associated channels"

  # Create a new device and create user if it does not exist
  #
  #
  @create: (obj, cb) ->
    user =
      id: obj.userId
      ip: obj.ip
    User.findOrCreate user, (err, reply) =>
      obj.userId = user.id unless obj.userId
      console.log this.name
      new this(obj).save(cb)

module.exports = Device
