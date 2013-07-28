MessageCounter = require("../models/message_counter")

# Class for sending messages via Socket.io / HTML5 Websockets
#
#
class WebSocketDispatcher
  constructor: (@io, @device) ->
    console.log "websocket dispatch"

    token = device.get("webSocketToken")
    console.log "send to socket #{token}"
    @socket = io.sockets.sockets[token]

  dispatch: (@message) ->
    unless @socket
      return

    # message for channel
    if @message.get("channelId")
      @message.channel (err, channel) =>
        @io.sockets.in(channel.get("name")).send @message.get "text"
    # message for single user
    else
      @socket.send @message.get "text"

    # increase message counter and send event for demo frontend
    MessageCounter.value (err, value) =>
      @io.sockets.in('registeredDevices').volatile.emit "sent_message_count", value


module.exports = WebSocketDispatcher
