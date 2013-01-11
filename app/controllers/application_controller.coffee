Application = require("../models/application")

exports.index = (req, res) ->
  Application.all (err, apps)->
    if err
      res.json 500, 
        error: err
    else
      res.json (
        applications: apps
      )

exports.new = (req, res) ->
  res.send "new user"
  
exports.create = (req, res) ->

  app = new Application(req.query)

  app.save (err, app) ->
    if err
      res.json 500, 
        error: err
    else
      res.json 200, (
        application: app
      )

exports.show = (req, res) ->
  Application.find req.params.application, (err, app) ->
    if app

      app.users (err, users) ->

        
        res.json 200, (
          application: app
          users: users
        )

    else
      res.json 500, err

exports.edit = (req, res) ->
  res.send "edit user " + req.params.user

exports.update = (req, res) ->
  res.send "update user " + req.params.user

exports.destroy = (req, res) ->
  User.find req.params.user, (err, user) ->
    res.send "delete user " + user.delete (err, reps) ->
      console.log err
      console.log reps
    
  
  

