
###
 Module dependencies
###

path                = require('path')
http                = require('http')
express             = require('express')
bunyan              = require('bunyan')
coffeeScript        = require('coffee-script')
nconf               = require('nconf') # global
redis               = require('redis')
RedisStore          = require('connect-redis')(express)
SocketRedisStore    = require("socket.io/lib/stores/redis")
SocketController    = require('./app/controllers/socket_controller')
WebClientController = require('./app/controllers/web_client_controller')
Resource            = require('express-resource')
io                  = require('socket.io')
User                = require('./app/models/user')

###
 Set config file
###

nconf.argv().env().file file: path.join(__dirname, "config", "global.json")

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
app = express()

app.configure ->
  app.set "port", process.env.PORT or 3000
  app.use express.compress()
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.set "view engine", "jade"
  app.use '/js', express.static(path.join(__dirname,'/public/js'))
  app.use '/css', express.static(path.join(__dirname, '/public/css'))
  app.set "views", path.join(__dirname, "app/views")
  app.use express.favicon()
  app.use express.logger("dev")


###
 Server routes
###


applications = app.resource 'applications', require('./app/controllers/application_controller')
messages     = app.resource 'messages', require('./app/controllers/message_controller')
devices      = app.resource 'devices', require('./app/controllers/device_controller')
users        = app.resource 'users', require('./app/controllers/user_controller')

applications.add users
applications.add devices
users.add messages
users.add devices

users        = app.resource 'users', require('./app/controllers/user_controller')

webClientController = new WebClientController(app)

console.log app.routes

###
 Start listening to port
###
server = http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")


###
 Socket.io
###

io = io.listen(server)

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
  io.set "log level", 3

  # enable transport channels to use

  io.set "transports", ["websocket", "htmlfile", "xhr-polling", "jsonp-polling"]

  io.set "store", new SocketRedisStore(
    redis: require('socket.io/node_modules/redis')
    redisPub: pub
    redisSub: sub
    redisClient: store
  )


socketController = new SocketController(io)
