User = require("../models/user")

exports.index = (req, res) ->
  User.all (err, users)->
    if err
      res.json 500, 
        error: err
    else
      res.json 
        users: users

exports.new = (req, res) ->
  res.send "new user"
  
exports.create = (req, res) ->

  console.log req.query
  a = new User(
    name: req.query.name
    applicationId: req.query.applicationId
  )
  a.save (err, user)->
    

  res.send "create user"

exports.show = (req, res) ->
  User.find req.params.user, (err, user) ->
    if user
      res.json 200, user
      
      user.messages  (err, messages) ->
        console.log messages
      user.application (err, application) ->
        console.log application

    else
      res.send "user not found"

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
  
  
console.log exports
