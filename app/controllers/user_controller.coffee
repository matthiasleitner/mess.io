ResourceController = require("./resource_controller")
User = require("../models/user")
Application = require("../models/application")

class UserController extends ResourceController
  constructor: ->
    super(User)

  create: (req, res) ->
    console.log req.query


    applicationId = req.query.applicationId || req.params.application


    Application.find applicationId, (err, application) =>
      if application
        a = new User
          name: req.query.name || req.body.name
          applicationId: applicationId

        a.save (err, user) ->
          res.send
            success: true
            user_id: user.id

      else
        res.send
          success: true
          reason: "Application not found"


module.exports = UserController

