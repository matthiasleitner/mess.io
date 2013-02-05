Message = require("../models/message")
User = require("../models/user")
ResourceController = require("./resource_controller")

class MessageController extends ResourceController
  constructor: ->
    super(Message)

  create: (req, res) ->
    params = req.params
    
    if req.param("text")

      User.find params.user, (err, user) =>
        if user
          a = new Message
            text: req.param("text")
            applicationId: req.params.application
            userId: user.id
            payload: req.body("payload") #json payload
            scheduledFor: req.param("scheduledFor")
          
          a.save (err, reply) ->
            res.send reply
        else
          res.send "user not found"
    else 
      res.send "not text given"
    
module.exports = MessageController