root = exports ? this
socketIOHost = "http://"+document.domain+":5002"

class root.Mess extends EventEmitter
  constructor: (@appKey, @userId = null) ->
    # array holding all active connections
    @connections = []
    @socket = io.connect socketIOHost,
      secure: false
    @bindEvents()

  register: () ->
    @socket.emit "register",
      userId: @userId
      userAuth: @userAuth
      applicationKey: @appKey
      browserFingerprint: $.fingerprint()

  clientList: (cb) ->
    @socket.emit "socketList", cb

  announce: (text) ->
    @socket.emit "announce", text

  sendMessage: (data) ->
    @socket.send data

  join: (channelId, cb = null) ->
    @socket.emit "joinChannel", channelId, cb

  leave: (channelId, cb = null) ->
    @socket.emit "leaveChannel", channelId, cb

  channelList: (cb) ->
    @socket.emit "channelList", cb


  bindEvents: ->
    @socket.on "connect", =>

      @socket.emit "getUserId",
        applicationKey: @appKey
        browserFingerprint: $.fingerprint(), (data) =>
          console.log data
          @emit "userKey", data.key
          @userId = data.id
          @userAuth = data.auth
          @register()

      @socket.on "userKey", (data) =>
        @emit "userKey", data

      @socket.on "connection_count", (data) =>
        @emit "connection_count",data

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
      window.setTimeout( =>
        sock = io.connect @host,
          'force new connection': true
        sock.on "connection_count", (data) =>
          $(".clients").text(data)
        @connections.push sock
      , num*100)

  spwanConnection: ->
    @connections.push io.connect @host,
      'force new connection': true


