ResourceController = require("./resource_controller")
User = require("../models/user")

class UserController extends ResourceController
  constructor: ->
    super(User)

  create: (req, res) ->
    console.log req.query

    a = new User
      name: req.query.name
      applicationId: req.query.applicationId || req.params.application
    
    a.save (err, user)->
      res.send "created user"

module.exports = UserController
  
