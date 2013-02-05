
gcm = require('node-gcm')

class GCMDispatcher
  constructor: (@app, @device, @retries = 4) ->
    @gcmKey = "AIzaSyD4gy-ro9l-X9OfvfDH8EaaqGgjmyOWxW8"# app.gcmKey 
    @gcmDeviceKey = @device.get("gcmToken")
    @gcmDeviceKey = "APA91bHz6yG8WOeEe33iB3s7HSz9nGM9xNc-r9QoG_1-bt2r4iTOceieXMjhZ2B1U6U3-4Nw8M4roxK6RwDOUtL8Yq_bauqL73yHR2wAUljfxDuqmLwtfFgV1OoLlXvs6iSPQnu5xlz2oyYai5HyTMEiCiLqgcYZUasokgdvPzYq_6t3MAkUMj0"
    
  dispatch: (message) ->
    gcmMessage = new gcm.Message()
    gcmSender = new gcm.Sender(@gcmKey)

    registrationIds = []

    gcmMessage.addData "key1", "message1"
    gcmMessage.addData "message", message.get "text"
    
    #message.data = @message.payload
    
    # Optional

    # collapseKey: An arbitrary string (such as "Updates Available") that is used to collapse 
    # a group of like messages when the device is offline, 
    # so that only the last message gets sent to the client. 

    # message.collapseKey = @message.collapseKey

    # delayWhileIdle: If included, indicates that the message should not be sent immediately if the device is idle.
    # The server will wait for the device to become active, and then only the last message for each collapse_key value will be sent. 
    # defaults to false
    # message.delayWhileIdle = true

    # time in seconds a message is kept in GCM storage if the device is offline - default is 4 weeks
    gcmMessage.timeToLive = 60 * 60 * 24 

    # push registration ids 
    registrationIds.push @gcmDeviceKey

    # Parameters: message instance, registrationIds array, number of retries, callback
    sender.send gcmMessage, registrationIds, @retries, (err, result) ->
      console.log "gcm result"
      console.log result

module.exports = GCMDispatcher
