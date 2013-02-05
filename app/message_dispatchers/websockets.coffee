MessageCounter = require("../models/message_counter")

# Class for sending messages via Socket.io / HTML5 Websockets
#
#
class WebSocketDispatcher
  constructor: (@io, @device) ->
    token = device.get("webSocketToken")
    @socket = io.sockets.sockets[token]
  dispatch: (@message)->
    if @socket
      @socket.send @message.get "text"

    MessageCounter.value (err, value) =>
      @io.sockets.in('registeredDevices').emit "sent_message_count", value


module.exports = WebSocketDispatcher
