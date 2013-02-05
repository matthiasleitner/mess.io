RedisObject   = require("./redis_object")

# Message model represents a message delivered through the service
#
#
class Message extends RedisObject

  @belongsTo: ["application", "user"]

  # override save to enqueue message
  save: (cb) ->
    if @id 
      super cb
    else
      # after message is saved enqueue it for delivery
      super (err, message) =>
        require("../workers/message_worker").enqueue(@id, cb)    
     

module.exports = Message

