Application = require("../models/application")

exports.index = (req, res) ->
  res.send "user index"

exports.new = (req, res) ->
  res.send "new user"
  
exports.create = (req, res) ->
  app = new Application(name: req.query.name)
  app.save (err, app) ->
    res.json(500, { error: 'message' })

exports.show = (req, res) ->
  console.log req.params

  Application.find(req.params.application, (err, app) ->
    if app
      res.json 200, app
    else
      res.send "user not found"
  )

exports.edit = (req, res) ->
  res.send "edit user " + req.params.user

exports.update = (req, res) ->
  res.send "update user " + req.params.user

exports.destroy = (req, res) ->
  User.find(req.params.user, (err, user) ->
    res.send "delete user " + user.delete((err, reps) ->
      console.log err
      console.log reps
      )
  )
  
  

