RedisRecord = require("redis-record")
bcrypt = require('bcrypt')

# Account representing owner of applications
#
#
class Account extends RedisRecord
  @hasMany:  ["applications"]
  @lookUpBy: ["email"]

  constructor: (@obj) ->
    @set("api_key", @constructor.generateKey())
    super(@obj)

  setPassword: (password, cb) ->
    bcrypt.hash password, 8, (err, hash) =>
      @set("password", hash)
      cb(err, hash)

  verifyPassword: (password, cb) ->
    bcrypt.compare password, @get("password"), (err, res) =>
      cb(err, res)


module.exports = Account