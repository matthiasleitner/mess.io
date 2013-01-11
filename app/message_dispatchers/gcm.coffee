
apns = require('node-gcm')

class GCMDispatcher
  constructor: (@message) ->

    message.application (err, app) ->
      @gcmKey = app.gcmKey #"6ee7b0493efd3157815eab98ab14b479be1f1c14b24e5f8bb64565eca688b719"
    
  dispatch: (cb) ->
    
    message = new gcm.Message()
    sender = new gcm.Sender(@gcmKey)

    registrationIds = []

    # Optional
    message.addData "key1", "message1"
    message.collapseKey = "demo"
    message.delayWhileIdle = true
    message.timeToLive = 3

    # At least one required
    registrationIds.push "regId1"


    ###
    	Parameters: message-literal, registrationIds-array, No. of retries, callback-function
    ###
    sender.send message, registrationIds, 4, (result) ->
      console.log result

module.exports = GCMDispatcher
