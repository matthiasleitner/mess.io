
###
 Module dependencies
###

path                = require('path')
https               = require("https")
http                = require("http")
fs                  = require("fs")
express             = require('express')
bunyan              = require('bunyan')
coffeeScript        = require('coffee-script')
config              = require('./config').settings
redis               = require('redis')
socketio            = require('socket.io')
RedisStore          = require('connect-redis')(express)
SocketRedisStore    = require("socket.io/lib/stores/redis")
SocketController    = require('./app/controllers/socket_controller')
WebClientController = require('./app/controllers/web_client_controller')
Resource            = require('express-resource')

User                = require('./app/models/user')
MessageWorker       = require('./app/workers/message_worker')
kue                 = require('kue')
cookie              = require('cookie')
cluster             = require("cluster")

###
  Catch exceptions
###
#process.on "uncaughtException", (exception) ->
#  console.log exception


###
 Logging
###

# logs thrown errors
ServerLog = bunyan.createLogger(
  name: "ServerLog"
  streams: [path: path.join(__dirname, "logs", "server.log")]
)

AccessLog = bunyan.createLogger(
  name: "AccessLog"
  streams: [path: path.join(__dirname, "logs", "access.log")]
)

# global logger
log = bunyan.createLogger(
  name: "CustomLog"
  streams: [path: path.join(__dirname, "logs", "custom.log")]
)

###
 Server
###
app     = express()
sessionStore = redis.createClient()

app.configure ->
  app.set "port", process.env.PORT or config.port
  app.use express.compress()
  app.use express.bodyParser
    uploadDir: path.join(__dirname,'/public/tmp')
  app.use express.methodOverride()
  app.use express.cookieParser()
  app.use express.session
    secret: process.env.CLIENT_SECRET or "super secret string"
    maxAge : new Date Date.now() + 7200000 # 2h Session lifetime
    store: new RedisStore {client: sessionStore}
  app.use '/js', express.static(path.join(__dirname,'/public/js'))
  app.use '/css', express.static(path.join(__dirname, '/public/css'))
  app.set "view engine", "jade"
  app.set "views", path.join(__dirname, "app/views")
  app.use express.favicon()
  app.use express.logger("dev")
  

###
 Start listening to port
###


#https
# options =
#   key: fs.readFileSync "server.key"
#   cert: fs.readFileSync "server.crt"
# server = https.createServer(options, app).listen app.get("port"), ->
#   console.log "Express server listening on port " + app.get("port")

server = http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")


###
 Socket.io
###

io = socketio.listen(config.socketIOPort)
io.set "log level",3
# io.disable('heartbeats')
# init redis clients for socket.io store
pub   = redis.createClient()
sub   = redis.createClient()
store = redis.createClient()

# authenticate for redis
redisPassword = ""

pub.auth redisPassword, (err) ->
  throw err  if err

sub.auth redisPassword, (err) ->
  throw err  if err

store.auth redisPassword, (err) ->
  throw err  if err


# numCPUs = require("os").cpus().length
# if cluster.isMaster
#   i = 0

#   while i < numCPUs
#     cluster.fork()
#     i++
# else
io.configure ->

  # send minified client
  io.enable "browser client minification" 
  # apply etag caching logic based on version number
  io.enable "browser client etag"
  # gzip the javascript client
  io.enable "browser client gzip"
  
  # reduce logging
  # 0 - error
  # 1 - warn
  # 2 - info
  # 3 - debug
  io.set "log level", 0

  # enable transport channels to use

  io.set "transports", ["websocket", "htmlfile", "xhr-polling", "jsonp-polling"]
  #io.disable('heartbeats')
  io.set "store", new SocketRedisStore
    redis: require('socket.io/node_modules/redis')
    redisPub: pub
    redisSub: sub
    redisClient: store

    # io.set "authorization", (data, callback) ->
    #   #console.log data
    #   if data.headers.cookie

    #     ck = cookie.parse(data.headers.cookie)
    #     ck = ck["connect.sid"].substr(2, ck["connect.sid"].indexOf(".")-2)

    #     # check if there is a matching session
    #     sessionStore.get "sess:#{ck}", (err, session) ->
    #       if err or not session
    #         callback "Error", false
    #       else
    #         data.session = session
    #         callback null, true
    #   else
    #     callback "No cookie", false
  

###
 Server routes
###


UserController = require('./app/controllers/user_controller')
DeviceController = require('./app/controllers/device_controller')
MessageController = require('./app/controllers/message_controller')
userController = new UserController
deviceController = new DeviceController
messageController = new MessageController

applications = app.resource 'applications', new (require('./app/controllers/application_controller'))
users        = app.resource 'users', userController
messages     = app.resource 'messages', messageController
devices      = app.resource 'devices', deviceController


# nest controllers
applications.add users
applications.add devices
users.add messages
users.add devices

# add users as standalone resource

users        = app.resource 'users', userController
devices      = app.resource 'devices', deviceController
messages     = app.resource 'messages', messageController

# init webclient controller for testing
webClientController = new WebClientController(app, io)

socketController = new SocketController(io)

###
 Kue process queue
###

# bind kue interface
kue.app.listen(3001)

messageWorker = new MessageWorker(io, 20)
