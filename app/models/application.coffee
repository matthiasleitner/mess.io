RedisObject = require("./redis_object")

class Application extends RedisObject

  @hasMany: ["users", "devices", "channels", "messages"]
  @lookUpBy: ["key"]
  @hasUniqKey: true
  
module.exports = Application
