Device = require("../models/device")
cookie = require('cookie')
class SocketController

  constructor: (@io) ->
    io.sockets.on "connection", (socket) ->
      console.log "new connection -------------------------$$$$$$$$$$$$$$$$$$$$$$$"

      #console.log io.sockets.manager.connected
      #socket.broadcast.emit "socketList", io.sockets.manager.connected

      socket.broadcast.emit "connection_count", Object.keys(io.sockets.sockets).length
      socket.emit "connection_count", Object.keys(io.sockets.sockets).length
      

      socket.on "channelList", (fn) ->
        fn(io.sockets.manager.connected)      

      socket.on "socketList", (fn) ->
        #console.log io.sockets.clients()
        fn(io.sockets.manager.connected)

      socket.on "announce", (data) ->
        socket.broadcast.emit "message", data

      socket.on "joinChannel", (data) ->        
        client.join data.room

      socket.on "leaveChannel", (data) ->        
        client.leave data.room

      socket.on "error", (data) ->
        console.log "error ############################################"
        console.log data

      socket.on "message", (data) ->
        #console.log socket.id
        #console.log io.sockets.sockets
        #console.log io.sockets.sockets[socket.id].emit "message", data
        #console.log io.sockets.manager.connected
        #console.log data

      socket.on "register", (data) ->
        #socket.emit "connection_count", Object.keys(io.sockets.sockets).length

        #console.log data
        #console.log cookie.parse(socket.handshake.headers.cookie)["connect.sid"]
        #console.log socket.handshake["headers"]["user-agent"]

        socket.set "userId", data.userId
        data.webSocketToken = socket.id
        data.transport = socket.transport
        data.handshake = JSON.stringify(socket.handshake)
        data.ip = socket.handshake.address.address

        # device = new Device(data).save (err, device) =>
        #   #console.log device
          
        #   #console.log device.supportedChannels()
        #   #console.log device.supportsChannel("webSocket")
        #   #device.user (err, user) ->
        #     #console.log user
    
        
        Device.create data, (err, device) =>

          socket.emit "deviceKey", device.key
          socket.set "deviceId", device.id
          console.log "device key is: "
          console.log device.get("key")

          device.user (err, user) =>
            console.log err
            console.log "device user id is: "
            console.log user.get "key"

            socket.emit "userKey", user.get "key"
          # setTimeout (=>
          #   Device.findBy "key", device.get("key"), (err, device) =>
          #     console.log err
          #     console.log "found by key "
          #     console.log device), 1000
        

      socket.on "connect", (data) ->
        console.log data

      socket.on "disconnect", (data) ->
        console.log socket.id
        socket.get "deviceId", (err, deviceId) =>
          Device.find deviceId, (err, device) =>
            device.removeChannel("webSocket") if device

          console.log "device with id: #{deviceId} disconnected -------------------------##################################"

        socket.get "userId", (err, name) ->
          console.log "Chat message by ", name

        console.log "disconnected socket"
        console.log data
  	
module.exports = SocketController
