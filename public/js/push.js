// Generated by CoffeeScript 1.3.3
(function() {
  var root,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  root.Push = (function(_super) {

    __extends(Push, _super);

    function Push(host) {
      this.host = host;
      this.connections = [];
      this.socket = io.connect(this.host, {
        secure: false
      });
      this.bindEvents();
    }

    Push.prototype.register = function(userId) {
      return this.socket.emit("register", {
        userId: userId,
        browserFingerprint: $.fingerprint()
      });
    };

    Push.prototype.clientList = function(cb) {
      return this.socket.emit("socketList", cb);
    };

    Push.prototype.announce = function(text) {
      return this.socket.emit("announce", text);
    };

    Push.prototype.sendMessage = function(data) {
      return this.socket.send(data);
    };

    Push.prototype.joinChannel = function(channelId, cb) {
      if (cb == null) {
        cb = null;
      }
      return this.socket.emit("joinChannel", channelId, cb);
    };

    Push.prototype.leaveChannel = function(channelId, cb) {
      if (cb == null) {
        cb = null;
      }
      return this.socket.emit("leaveChannel", channelId, cb);
    };

    Push.prototype.channelList = function(cb) {
      return this.socket.emit("channelList", cb);
    };

    Push.prototype.bindEvents = function() {
      var _this = this;
      this.socket.on("userKey", function(data) {
        return _this.emit("userKey", data);
      });
      this.socket.on("news", function() {
        return news.emit("woot");
      });
      this.socket.on("spwanConnection", function(count) {
        return this.spwanConnections(count);
      });
      this.socket.on("socketList", function(data) {
        return console.log(data);
      });
      this.socket.on("error", function(data) {
        return console.log(data);
      });
      return this.socket.on("message", function(msg) {
        _this.socket.emit("akn");
        return _this.emit("message", msg);
      });
    };

    Push.prototype.spwanConnections = function(count) {
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

    Push.prototype.spwanConnection = function() {
      return this.connections.push(io.connect(this.host, {
        'force new connection': true
      }));
    };

    return Push;

  })(EventEmitter);

}).call(this);