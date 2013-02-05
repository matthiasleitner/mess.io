root = exports ? this
class root.Push extends EventEmitter

  constructor: (@host) ->
    # array holding all active connections
    @connections = []
    
    @socket = io.connect @host,
      secure: false
    @bindEvents()

  register: (userId) ->
    @socket.emit "register",
      userId: userId
      browserFingerprint: $.fingerprint()

  clientList: (cb) ->
    @socket.emit "socketList", cb

  announce: (text) ->
    @socket.emit "announce", text
    
  sendMessage: (data) ->
    @socket.send data

  joinChannel: (channelId, cb = null) ->
    @socket.emit "joinChannel", channelId, cb

  leaveChannel: (channelId, cb = null) ->
    @socket.emit "leaveChannel", channelId, cb

  channelList: (cb) ->
    @socket.emit "channelList", cb

  bindEvents: ->
    @socket.on "userKey", (data) =>
      @emit "userKey", data

    @socket.on "news", ->
      news.emit "woot"

    @socket.on "spwanConnection", (count) ->
      @spwanConnections(count)

    @socket.on "socketList", (data) ->
      console.log data

    @socket.on "error", (data) ->
      console.log data

    @socket.on "message", (msg) =>
      @socket.emit "akn"
      @emit "message",msg

  spwanConnections: (count) ->
    for num in [1..count]
      # spwan new connection every 100 ms
      window.setTimeout(=>
        sock = io.connect @host,
          'force new connection': true
        sock.on "connection_count", (data) =>
          $(".clients").text(data)
        @connections.push sock
      , num*100)

  spwanConnection: ->
    @connections.push io.connect @host,
      'force new connection': true


