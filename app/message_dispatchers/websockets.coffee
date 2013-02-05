class WebSocketDispatcher
  constructor: (@io, @device) ->
    token = device.get("webSocketToken")
    @socket = io.sockets.sockets[token]
  dispatch: (@message)->
    
    console.log @message.get "text"
    if @socket
      console.log "send message to socket #{@message.get("text")}"
      @socket.send @message.get "text"


module.exports = WebSocketDispatcher
