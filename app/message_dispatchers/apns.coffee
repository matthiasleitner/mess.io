
apns = require('apn')

class APNSDispatcher
  options =
    cert: "cert.pem"
    key: "key.pem"
    gateway: "gateway.sandbox.push.apple.com"
    errorCallback: `undefined`
    cacheLength: 100
    autoAdjustCache: true
    connectionTimeout: 0

  constructor: (@message) ->
    @token = "6ee7b0493efd3157815eab98ab14b479be1f1c14b24e5f8bb64565eca688b719"
    console.log(options)
  dispatch: ->
    
    apnsConnection = new apns.Connection(options)
    apnsDevice = new apns.Device(@token)

    note = new apns.Notification()
    note.expiry = Math.floor(Date.now() / 1000) + 3600 # Expires 1 hour from now.
    note.badge = 5
    note.alert = "it works perfect"
    note.payload = messageFrom: "Caroline"
    note.device = apnsDevice

    apnsConnection.sendNotification note

#exports.APNSDispatcher = APNSDispatcher
module.exports = APNSDispatcher
