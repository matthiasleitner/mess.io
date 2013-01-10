bases = require("bases")
crypto = require("crypto")
RedisObject = require("./redis_object")

class Application extends RedisObject

  constructor: (@obj) ->
    unless obj.key
      obj.key = Application.generateKey()
    
    super(obj)

  # ---------------------------------------------------------
  # static methods
  # ---------------------------------------------------------

  @generateKey: (length = 32) ->
  
    maxNum = Math.pow(62, length)
    numBytes = Math.ceil(Math.log(maxNum) / Math.log(256))

    loop
      bytes = crypto.randomBytes(numBytes)
      num = 0
      i = 0

      while i < bytes.length
        num += Math.pow(256, i) * bytes[i]
        i++
      break unless num >= maxNum

    bases.toBase62 num


module.exports = Application
