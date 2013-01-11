RedisObject   = require("./redis_object")
MessageWorker = require("../workers/message_worker")


class Message extends RedisObject

  @belongsTo: ["application", "user"]

  save: (cb) ->
    if @id 
      super cb
    else
      super (err, message) =>
        MessageWorker.enqueue(@obj, cb)    
     

module.exports = Message

