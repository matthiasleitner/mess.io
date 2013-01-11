Device = require("../models/device")

class SocketController

  constructor: (@io) ->
    io.sockets.on "connection", (socket) ->
      console.log io.sockets.manager.connected

      socket.broadcast.emit "socketList", io.sockets.manager.connected
      socket.on "socketList", (fn) ->
        fn(io.sockets.manager.connected)
        console.log io.sockets.clients()[1].handshake

      socket.on "register", (data) ->
        data.socketID = socket.id
        console.log socket.handshake["headers"]["user-agent"]
        socket.set 'nickname', "test", ->
          socket.emit('ready')

        data.supportedChannel = socket.transport
        data.handshake = JSON.stringify(socket.handshake)

        device = new Device(data).save( (err, device) ->
          )
        console.log(data)

      socket.on "connect", (data) ->
        console.log data
      socket.on "disconnect", (data) ->
        console.log data
  	
module.exports = SocketController
