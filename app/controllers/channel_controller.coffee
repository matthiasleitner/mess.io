ResourceController = require("./resource_controller")
Channel = require("../models/channel")

class ChannelController extends ResourceController
  constructor: ->
    super(Channel)

  create: (req, res) ->
    console.log req.query

    # create channel and assign to application
    a = new Channel
      name: req.query.name
      applicationId: req.query.applicationId || req.params.application

    a.save (err, user)->
      res.send "created channel"

module.exports = ChannelController

