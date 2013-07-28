apns = require('apns')

# Class for sending messages via Apple Push Notification Service
#
#
class APNSDispatcher
  #
  # TODO: load proper cert and key for given device
  #
  constructor: (@app, @device, @expiry = 3600) ->
    @options =
      certFile: @app.get("apnsCert")
      keyFile: @app.get("apnsKey")
      gateway: "gateway.sandbox.push.apple.com" # change this to non sandbox for production

    @token = @device.get("apnsToken") #"6ee7b0493efd3157815eab98ab14b479be1f1c14b24e5f8bb64565eca688b719"

  dispatch: (@message) ->

    apnsConnection = new apns.Connection(@options)
    apnsDevice = new apns.Device(@token)
    notification = new apns.Notification()

    # set expiry from instance variable
    notification.expiry = Math.floor(Date.now() / 1000) + @expiry
    notification.badge = 5

    # set text and payload
    notification.alert = @message.get("text")
    notification.payload = @message.get("payload")
    notification.device = apnsDevice

    console.log notification
    apnsConnection.sendNotification notification

module.exports = APNSDispatcher
