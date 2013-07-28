Device = require("../models/device")
Application = require("../models/application")
User = require("../models/user")
cookie = require('cookie')

# Controller for WebSocket interaction
#
#
class SocketController

  constructor: (@io) ->
    io.sockets.on "connection", (socket) ->
      console.log "new connection -------------------------$$$$$$$$$$$$$$$$$$$$$$$"

      #console.log io.sockets.manager.connected
      #socket.broadcast.emit "socketList", io.sockets.manager.connected

      #socket.broadcast.emit "connection_count", Object.keys(io.sockets.sockets).length
      socket.emit "connection_count", Object.keys(io.sockets.sockets).length
      io.sockets.in('registedDevices').emit "connection_count", Object.keys(io.sockets.sockets).length

      # respond to various messages
      socket.on "socketList", (fn) ->
        #console.log io.sockets.clients()
        fn(io.sockets.manager.connected)

      socket.on "announce", (data) ->
        socket.broadcast.emit "message", data

      socket.on "joinChannel", (data) ->
        socket.get "userId", (err, userId) =>
          User.find userId, (err, user) =>
            user.joinChannel

        socket.join data.room

      socket.on "leaveChannel", (data) ->
        socket.leave data.room

      socket.on "error", (data) ->
        console.log "socket.io error ############################################"
        console.log data

      socket.on "message", (data) ->
        #console.log io.sockets.sockets
        #console.log io.sockets.sockets[socket.id].emit "message", data
        #console.log io.sockets.manager.connected

      # request dummy userId for demo
      socket.on "getUserId", (data, fn) ->
        Application.findBy "key", data.applicationKey, (err, application) =>
          if application
            data.applicationId = application.id
            user = new User(data)
            user.save (err, user) =>
              userAuth = application.signValue(user.id)
              socket.set "userId", user.id
              response =
                key: user.get("key")
                id: user.id
                auth: userAuth
              fn(response)


      socket.on "register", (data) ->
        Application.findBy "key", data.applicationKey, (err, application) =>
          unless application
            socket.emit "message", "unkown application"
            return


          unless application.verifySigniture(data.userId, data.userAuth)
           socket.emit "message", "user auth failed"
           return

          #socket.emit "connection_count", Object.keys(io.sockets.sockets).length
          #console.log cookie.parse(socket.handshake.headers.cookie)["connect.sid"]
          #console.log socket.handshake["headers"]["user-agent"]

          data.webSocketToken = socket.id
          data.transport = socket.transport
          data.applicationId = application.get "id"
          data.handshake = JSON.stringify(socket.handshake)
          data.ip = socket.handshake.address.address

          socket.join "registeredDevices"

          Device.create data, (err, device) =>
            socket.emit "deviceKey", device.key
            socket.set "deviceId", device.id

            # send user key back to client for demo
            # device.user (err, user) =>
            #  socket.emit "userKey", user.get "key"

      socket.on "connect", (data) ->
        console.log data

      socket.on "disconnect", (data) ->
        #console.log socket.id
        socket.get "deviceId", (err, deviceId) =>
          Device.find deviceId, (err, device) =>
            if device
              device.removeChannel("webSocket")


          console.log "device with id: #{deviceId} disconnected"

        socket.get "userId", (err, userId) ->
          console.log "user with id: #{userId} disconnected"


module.exports = SocketController
