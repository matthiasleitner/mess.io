Message = require("../models/message")

exports.index = (req, res) ->
  res.send "message index"

exports.new = (req, res) ->
  res.send "new message"
  
exports.create = (req, res) ->
  
  a = new Message(
    name: req.query.name
    applicationId: req.params.application
    userId: req.params.user
  )
  
  a.save (err, reply) ->
    Application.all()
    
  res.send "create message"

exports.show = (req, res) ->
  res.send "show message " + req.params.message + " " + req.params.user

exports.edit = (req, res) ->
  res.send "edit message " + req.params.message

exports.update = (req, res) ->
  res.send "update message " + req.params.message

exports.destroy = (req, res) ->
  res.send "destroy message " + req.params.message

