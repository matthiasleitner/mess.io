
Device = require("../models/device")


class SocketController

  constructor: (@io) ->
    io.sockets.on "connection", (socket) ->
      
      console.log socket.id

      socket.on "register", (data) ->
        data.socketID = socket.id
        device = new Device(data).save()
        
        console.log(data)

      socket.on "connect", (data) ->
        
        console.log data
      socket.on "disconnect", (data) ->
        console.log data
  	
module.exports = SocketController