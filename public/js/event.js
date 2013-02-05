// Generated by CoffeeScript 1.3.3
(function() {
  var root;

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  root.EventEmitter = (function() {

    function EventEmitter() {}

    EventEmitter.prototype.on = function(event, cb) {
      if (typeof cb === 'function') {
        this._handlers();
        if (!this.handlers[event]) {
          this.handlers[event] = [];
        }
        this.handlers[event].push(cb);
        return true;
      } else {
        return false;
      }
    };

    EventEmitter.prototype.unbind = function(event, cb) {
      if (!this.handlers) {
        return false;
      }
      if ((this.handlers[event] != null) && this.handlers[event].indexOf(cb) >= 0) {
        this.handlers[event].splice(this.handlers[event].indexOf(cb), 1);
        return true;
      } else {
        return false;
      }
    };

    EventEmitter.prototype.unbindAll = function() {
      this.handlers = {};
      return true;
    };

    EventEmitter.prototype.emit = function(event, data) {
      var cb, _i, _len, _ref;
      if (data == null) {
        data = {};
      }
      this._handlers();
      if ((this.handlers[event] != null) && this.handlers[event].length > 0) {
        _ref = this.handlers[event];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          cb = _ref[_i];
          if (typeof cb === 'function') {
            cb(data);
          }
        }
        return true;
      } else {
        return false;
      }
    };

    EventEmitter.prototype._handlers = function() {
      if (!this.handlers) {
        return this.handlers = {};
      }
    };

    return EventEmitter;

  })();

}).call(this);
