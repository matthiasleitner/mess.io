Message = require("../models/message")
Application = require("../models/application")
User = require("../models/user")
ResourceController = require("./resource_controller")

class MessageController extends ResourceController
  constructor: ->
    super(Message)

  create: (req, res) ->
    console.log "creating message"
    params = req.params
    console.log req.param("text")
    # TODO: build param validation chain and also check for existing application

    unless req.param("text")
      res.send "not text given"
      return

    Application.find params.application, (err, application) =>
      if application
        User.find params.user, (err, user) =>
          if user
            a = new Message
              text: req.param("text")
              applicationId: application.get("id")
              userId: user.id
              payload: req.param("payload")
              scheduledFor: req.param("scheduledFor")

            a.save (err, reply) ->
              res.send reply
          else
            res.send "user not found"
      else
        res.send "application not found"



module.exports = MessageController