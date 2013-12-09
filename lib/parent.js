(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  (function(window, document) {
    var Base, BaseLogging, Exception, Messages, toCamelCase, toUnderscore, urlEncode;
    if (win.Tagasauris) {
      return;
    }
    urlEncode = function(params) {
      var key, param, tail, v, value, _i, _j, _len, _len1;
      tail = [];
      if (params instanceof Array) {
        for (_i = 0, _len = params.length; _i < _len; _i++) {
          param = params[_i];
          if (param instanceof Array && param.length > 1) {
            tail.push("" + param[0] + "=" + (encodeURIComponent(param[1])));
          }
        }
      } else {
        for (key in params) {
          value = params[key];
          if (value instanceof Array) {
            for (_j = 0, _len1 = value.length; _j < _len1; _j++) {
              v = value[_j];
              tail.push("" + key + "=" + (encodeURIComponent(v)));
            }
          } else {
            tail.push("" + key + "=" + (encodeURIComponent(value)));
          }
        }
      }
      return tail.join('&');
    };
    toCamelCase = function(text) {
      return text.replace(/(_[a-z])/g, function($1) {
        return $1.toUpperCase().replace('_', '');
      });
    };
    toUnderscore = function(text) {
      return text.replace(/([A-Z])/g, function($1) {
        return '_' + $1.toLowerCase();
      });
    };
    Exception = (function() {
      function Exception(message) {
        this.message = message;
        this.name = 'Exception';
      }

      Exception.prototype.toString = function() {
        return this.message;
      };

      return Exception;

    })();
    Base = (function() {
      function Base() {}

      Base.prototype.set = function(key, value) {
        return this[key] = value;
      };

      Base.prototype.get = function(key, empty) {
        if (empty == null) {
          empty = null;
        }
        return this[key] || empty;
      };

      return Base;

    })();
    BaseLogging = (function(_super) {
      __extends(BaseLogging, _super);

      function BaseLogging(options) {
        if (options == null) {
          options = {};
        }
        this.set('logging', options.logging || false);
      }

      BaseLogging.prototype.log = function(message) {
        if (this.get('logging')) {
          return console.log("Tagasauris: " + message);
        }
      };

      return BaseLogging;

    })(Base);
    Messages = (function(_super) {
      var type, _i, _len, _ref;

      __extends(Messages, _super);

      function Messages(options) {
        var eventMethod, eventer, messageEvent;
        if (options == null) {
          options = {};
        }
        this.set('logging', options.logging || false);
        this.set('_messageReceivedListener', options.messageReceivedListener || null);
        eventMethod = win.addEventListener ? 'addEventListener' : 'attachEvent';
        eventer = win[eventMethod];
        messageEvent = eventMethod === 'attachEvent' ? 'onmessage' : 'message';
        eventer(messageEvent, this.messageReceiver(this), false);
      }

      Messages.prototype.log = function(message) {
        if (this.get('logging')) {
          return console.log("Tagasauris: " + message);
        }
      };

      Messages.prototype.isInIFrame = function() {
        return win.location !== win.parent.location;
      };

      Messages.prototype.sendMessage = function(type, message) {
        this.log("Sending message: " + type + " - " + message);
        return parent.postMessage({
          type: type,
          message: message
        }, doc.referrer);
      };

      Messages.prototype.messageReceiver = function(self) {
        return function(event) {
          self.log("Message received: " + event.data.type + " - " + event.data.message);
          if (typeof self._messageReceivedListener === 'function') {
            return self._messageReceivedListener(event.data.type, event.data.message);
          }
        };
      };

      _ref = ['success', 'info', 'warning', 'error'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        type = _ref[_i];
        Messages.prototype[toCamelCase("send_" + type + "_message")] = (function(_type) {
          return function(message) {
            return this.sendMessage(_type, message);
          };
        })(type);
      }

      return Messages;

    })(Base);
    return win.Tagasauris = {
      VERSION: '0.0.1',
      Messages: Messages
    };
  })(window, document);

}).call(this);
