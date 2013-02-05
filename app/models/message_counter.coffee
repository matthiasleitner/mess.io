redis  = require("redis")
db  = redis.createClient()
class MessageCounter
  @value: (cb) ->
    db.GET "messages_sent", cb
  @incr: ->
    db.INCR "messages_sent", (err, resp) ->

module.exports = MessageCounter