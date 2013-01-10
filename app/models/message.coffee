RedisObject = require("./redis_object")

class Message extends RedisObject
	belongsTo: ["application", "user"]
  


module.exports = Message

