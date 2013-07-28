RedisRecord = require("redis-record")
crypto = require("crypto")

class Application extends RedisRecord

  @hasMany: ["users", "devices", "channels", "messages"]
  @belongsTo: ["account"]
  @lookUpBy: ["key"]
  @hasUniqKey: true

  constructor: (@obj) ->
    unless @get("api_secret")
      @set("api_secret", @generateSecret())
    super(@obj)
    this

  # check if the signiture for the given value is valid and has been signed with the application secret
  #
  verifySigniture: (value, signiture) ->
    (signiture == @signValue(value))

  signValue: (value) ->
    crypto.createHmac('sha256', @get("api_secret")).update("#{value}").digest('hex')

  generateSecret: (length = 32) ->
    buf = crypto.randomBytes length
    buf.toString("hex")

  userCount: ->
    # TODO implement getter for users per application
    10


module.exports = Application
