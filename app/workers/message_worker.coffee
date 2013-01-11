kue  = require("kue")
jobs = kue.createQueue()

class MessageWorker

  klass = null

	constructor: (concurrency = 10) ->

    klass = @constructor

    # promote delayed jobs every 2 seconds
    jobs.promote 2000

    jobs.process "message", 10, klass._process

    jobs.on "job complete", (id) -> klass._completionHandler
    jobs.on "job failed",   (id) -> klass._failureHandler


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
    console.log job.data
    done("err")

  @_completionHandler: (id) ->
    kue.Job.get id, (err, job) ->
      return  if err
      job.remove (err) ->
        throw err  if err
        console.log "removed completed job #%d", job.id

  @_failureHandler: (id) ->
    console.log "job with id: #{id} failed!!!"

    kue.Job.get id-1, (err, job) ->
      console.log job
      return  if err
      job.remove (err) ->
        throw err if err
        console.log "removed completed job #%d", job.id

module.exports = MessageWorker