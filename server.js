// Generated by CoffeeScript 1.3.3

/*
 Module dependencies
*/


(function() {
  var AccessLog, RedisStore, Resource, ServerLog, SocketController, SocketRedisStore, User, WebClientController, app, applications, bunyan, coffeeScript, devices, express, http, io, log, messages, nconf, path, pub, redis, redisPassword, server, socketController, store, sub, users, webClientController;

  path = require('path');

  http = require('http');

  express = require('express');

  bunyan = require('bunyan');

  coffeeScript = require('coffee-script');

  nconf = require('nconf');

  redis = require('redis');

  RedisStore = require('connect-redis')(express);

  SocketRedisStore = require("socket.io/lib/stores/redis");

  SocketController = require('./app/controllers/socket_controller');

  WebClientController = require('./app/controllers/web_client_controller');

  Resource = require('express-resource');

  io = require('socket.io');

  User = require('./app/models/user');

  /*
   Set config file
  */


  nconf.argv().env().file({
    file: path.join(__dirname, "config", "global.json")
    /*
     Logging
    */

  });

  ServerLog = bunyan.createLogger({
    name: "ServerLog",
    streams: [
      {
        path: path.join(__dirname, "logs", "server.log")
      }
    ]
  });

  AccessLog = bunyan.createLogger({
    name: "AccessLog",
    streams: [
      {
        path: path.join(__dirname, "logs", "access.log")
      }
    ]
  });

  log = bunyan.createLogger({
    name: "CustomLog",
    streams: [
      {
        path: path.join(__dirname, "logs", "custom.log")
      }
    ]
  });

  /*
   Server
  */


  app = express();

  app.configure(function() {
    app.set("port", process.env.PORT || 3000);
    app.use(express.bodyParser());
    app.use(express.methodOverride());
    app.set("view engine", "jade");
    app.use('/js', express["static"](path.join(__dirname, '/public/js')));
    app.use('/css', express["static"](path.join(__dirname, '/public/css')));
    app.set("views", path.join(__dirname, "app/views"));
    app.use(express.favicon());
    return app.use(express.logger("dev"));
  });

  /*
   Server routes
  */


  applications = app.resource('applications', require('./app/controllers/application_controller'));

  messages = app.resource('messages', require('./app/controllers/message_controller'));

  devices = app.resource('devices', require('./app/controllers/device_controller'));

  users = app.resource('users', require('./app/controllers/user_controller'));

  applications.add(users);

  applications.add(devices);

  users.add(messages);

  users.add(devices);

  users = app.resource('users', require('./app/controllers/user_controller'));

  webClientController = new WebClientController(app);

  console.log(app.routes);

  /*
   Start listening to port
  */


  server = http.createServer(app).listen(app.get("port"), function() {
    return console.log("Express server listening on port " + app.get("port"));
  });

  /*
   Socket.io
  */


  io = io.listen(server);

  pub = redis.createClient();

  sub = redis.createClient();

  store = redis.createClient();

  redisPassword = "";

  pub.auth(redisPassword, function(err) {
    if (err) {
      throw err;
    }
  });

  sub.auth(redisPassword, function(err) {
    if (err) {
      throw err;
    }
  });

  store.auth(redisPassword, function(err) {
    if (err) {
      throw err;
    }
  });

  io.configure(function() {
    io.enable("browser client minification");
    io.enable("browser client etag");
    io.enable("browser client gzip");
    io.set("log level", 3);
    io.set("transports", ["websocket", "htmlfile", "xhr-polling", "jsonp-polling"]);
    return io.set("store", new SocketRedisStore({
      redisPub: pub,
      redisSub: sub,
      redisClient: store
    }));
  });

  socketController = new SocketController(io);

}).call(this);
