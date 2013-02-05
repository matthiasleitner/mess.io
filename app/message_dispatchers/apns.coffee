apns = require('apns')
class APNSDispatcher
  options =
    certFile: "cert.pem"
    keyFile: "key.pem"
    gateway: "gateway.sandbox.push.apple.com"


  constructor: (@device, @expiry = 3600) ->
    @token = device.apnsToken #"6ee7b0493efd3157815eab98ab14b479be1f1c14b24e5f8bb64565eca688b719" 
    
  dispatch: (@message) ->
    console.log "APNS dispatch ################################################"
    
    apnsConnection = new apns.Connection(options)
    apnsDevice = new apns.Device(@token)
    note = new apns.Notification()

    # set expiry from instance variable
    note.expiry = Math.floor(Date.now() / 1000) + @expiry 
    note.badge = 5
    note.alert = @message.get("text")
    note.payload = 
      test: @message.get("payload")
    note.device = apnsDevice
  
    console.log note
    apnsConnection.sendNotification note

module.exports = APNSDispatcher
