kue  = require("kue")
jobs = kue.createQueue()
APNSDispatcher = require("../message_dispatchers/apns")
GCMDispatcher = require("../message_dispatchers/gcm")
WebSocketDispatcher = require("../message_dispatchers/websockets")
Message = require("../models/message")
MessageCounter = require("../models/message_counter")
Device = require("../models/device")

# Class for processing queued jobs and init dispatching
#
#
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

  # Queue new message
  #
  #
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

  # Process queue message
  #
  #
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

              # browser clients
              if device.supportsChannel("webSocket")
                console.log "send message to socket with token %s", device.get("webSocketToken")
                socketDispatcher = new WebSocketDispatcher(klass.io, device)
                socketDispatcher.dispatch(message)

              # Android
              if device.supportsChannel("gcm")
                gcmDispatcher = new GCMDispatcher(null, device)
                gcmDispatcher.dispatch(message)

              # iOS and OS X devices
              if device.supportsChannel("apns")
                apnsDispatcher = new APNSDispatcher(device)
                apnsDispatcher.dispatch(message)

            done()

  # Completion handler - removes completed jobs
  #
  #
  @_completionHandler: (id) ->
    MessageCounter.incr()
    console.log "job with id: #{id} done"
    MessageWorker._remove(id)
    
  # Handler for failed jobs
  #
  #
  @_failureHandler: (id) ->
    console.log "job with id: #{id} failed!"
    MessageWorker._restart(id)
    
  # Helper for restarting job with given id
  #
  #
  @_restart: (id) ->
    kue.Job.get id, (err, job) ->
      throw err if err
      job.state('inactive').save()

  # Helper for removing jobs woth given id from queue
  #
  #
  @_remove: (id) ->
    kue.Job.get id, (err, job) ->
      throw err if err
      job.remove (err) ->
        throw err if err
        console.log "removed completed job #%d", job.id

      

module.exports = MessageWorker