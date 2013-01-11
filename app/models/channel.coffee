RedisObject = require("./redis_object")

class Channel extends RedisObject
	belongsTo: ["application"]

module.exports = Channel
