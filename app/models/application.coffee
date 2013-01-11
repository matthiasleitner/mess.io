RedisObject = require("./redis_object")

class Application extends RedisObject

  @hasMany: ["users"]

  constructor: (@obj) ->
    unless obj.key
      obj.key = RedisObject.generateKey()
    
    super(obj)

  # ---------------------------------------------------------
  # static methods
  # ---------------------------------------------------------




module.exports = Application
