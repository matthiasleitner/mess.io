kue  = require("kue")
jobs = kue.createQueue()
APNSDispatcher = require("../message_dispatchers/apns")
GCMDispatcher = require("../message_dispatchers/gcm")
WebSocketDispatcher = require("../message_dispatchers/websockets")
Message = require("../models/message")
Device = require("../models/device")

class MessageWorker
  klass = null
  constructor: (io, concurrency = 10) ->
    
    klass = @constructor
    klass.io = io
    # promote delayed jobs every 2 seconds
    jobs.promote 2000

    jobs.process "message", concurrency, klass._process

    jobs.on "job complete", klass._completionHandler
    jobs.on "job failed",   klass._failureHandler


  # ---------------------------------------------------------
  # static methods
  # ---------------------------------------------------------

  @enqueue: (obj, cb) -> 

    obj.title = "message to user: #{obj.userId}"

    job = jobs.create 'message', obj 
  
    if obj.scheduledFor

      # calculate difference to schedule date in ms 
      delay = new Date(parseInt(obj.scheduledFor)) - new Date()     
      job.priority('low').delay(delay)

    else
      job.priority('high')

    job.save (err) =>
      cb()

  @_process: (job, done) ->
    # find message for job
    console.log job.data


    # find message 
    Message.find job.data, (err, message) =>
      console.log "loaded message %j", message
      if message
        # load user for message
        message.user (err, user)  =>

          console.log "loaded user with id %s",user.id
          # get all devices of user
          user.devices (err, devices) =>
            console.log devices
            # serve all devices of user
            for device in devices
              device = new Device(device)

              if device.supportsChannel("webSocket")
                console.log "send message to socket with token %s", device.get("webSocketToken")
                socketDispatcher = new WebSocketDispatcher(klass.io, device)
                socketDispatcher.dispatch(message)
              if device.supportsChannel("gcm")
                gcmDispatcher = new GCMDispatcher(null, device)
                gcmDispatcher.dispatch(message)

              if device.supportsChannel("apns")
                apnsDispatcher = new APNSDispatcher(device)
                apnsDispatcher.dispatch(message)

            done()

  @_completionHandler: (id) ->
    kue.Job.get id, (err, job) ->
      return if err
      job.remove (err) ->
        throw err if err
        console.log "removed completed job #%d", job.id

  @_failureHandler: (id) ->
    console.log "job with id: #{id} failed!!!"

    kue.Job.get id, (err, job) ->
      throw err if err
      job.state('inactive').save()
      console.log job
      
      # 
  @_restart: (id) ->
    kue.Job.get id, (err, job) ->
      throw err if err
      job.state('inactive').save()

  @_remove: (id) ->
    kue.Job.get id, (err, job) ->
      throw err if err
      job.remove (err) ->
        throw err if err
        console.log "removed completed job #%d", job.id

      

module.exports = MessageWorker