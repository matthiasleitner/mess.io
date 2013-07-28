// Generated by CoffeeScript 1.3.3
(function() {
  var root, socketIOHost,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  socketIOHost = "http://" + document.domain + ":5002";

  root.Mess = (function(_super) {

    __extends(Mess, _super);

    function Mess(appKey, userId) {
      this.appKey = appKey;
      this.userId = userId != null ? userId : null;
      this.connections = [];
      this.socket = io.connect(socketIOHost, {
        secure: false
      });
      this.bindEvents();
    }

    Mess.prototype.register = function() {
      return this.socket.emit("register", {
        userId: this.userId,
        userAuth: this.userAuth,
        applicationKey: this.appKey,
        browserFingerprint: $.fingerprint()
      });
    };

    Mess.prototype.clientList = function(cb) {
      return this.socket.emit("socketList", cb);
    };

    Mess.prototype.announce = function(text) {
      return this.socket.emit("announce", text);
    };

    Mess.prototype.sendMessage = function(data) {
      return this.socket.send(data);
    };

    Mess.prototype.join = function(channelId, cb) {
      if (cb == null) {
        cb = null;
      }
      return this.socket.emit("joinChannel", channelId, cb);
    };

    Mess.prototype.leave = function(channelId, cb) {
      if (cb == null) {
        cb = null;
      }
      return this.socket.emit("leaveChannel", channelId, cb);
    };

    Mess.prototype.channelList = function(cb) {
      return this.socket.emit("channelList", cb);
    };

    Mess.prototype.bindEvents = function() {
      var _this = this;
      return this.socket.on("connect", function() {
        _this.socket.emit("getUserId", {
          applicationKey: _this.appKey,
          browserFingerprint: $.fingerprint()
        }, function(data) {
          console.log(data);
          _this.emit("userKey", data.key);
          _this.userId = data.id;
          _this.userAuth = data.auth;
          return _this.register();
        });
        _this.socket.on("userKey", function(data) {
          return _this.emit("userKey", data);
        });
        _this.socket.on("connection_count", function(data) {
          return _this.emit("connection_count", data);
        });
        _this.socket.on("spwanConnection", function(count) {
          return this.spwanConnections(count);
        });
        _this.socket.on("socketList", function(data) {
          return console.log(data);
        });
        _this.socket.on("error", function(data) {
          return console.log(data);
        });
        return _this.socket.on("message", function(msg) {
          _this.socket.emit("akn");
          return _this.emit("message", msg);
        });
      });
    };

    Mess.prototype.spwanConnections = function(count) {
      var num, _i, _results,
        _this = this;
      _results = [];
      for (num = _i = 1; 1 <= count ? _i <= count : _i >= count; num = 1 <= count ? ++_i : --_i) {
        _results.push(window.setTimeout(function() {
          var sock;
          sock = io.connect(_this.host, {
            'force new connection': true
          });
          sock.on("connection_count", function(data) {
            return $(".clients").text(data);
          });
          return _this.connections.push(sock);
        }, num * 100));
      }
      return _results;
    };

    Mess.prototype.spwanConnection = function() {
      return this.connections.push(io.connect(this.host, {
        'force new connection': true
      }));
    };

    return Mess;

  })(EventEmitter);

}).call(this);
