RedisObject   = require("./redis_object")

class Message extends RedisObject

  @belongsTo: ["application", "user"]

  save: (cb) ->
    if @id 
      super cb
    else
      # after message is saved enqueue it for dispatch
      super (err, message) =>
        require("../workers/message_worker").enqueue(@id, cb)    
     

module.exports = Message

