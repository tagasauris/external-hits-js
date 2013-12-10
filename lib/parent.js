(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  (function(window, document) {
    var Base, BaseLogging, Exception, Messages, ParentClient, toCamelCase, toUnderscore, urlEncode;
    if (window.Tagasauris) {
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

      Messages.types = ['success', 'info', 'warning', 'error', 'start'];

      function Messages(options) {
        var eventMethod, eventer, key, messageEvent, type, _i, _len, _ref;
        if (options == null) {
          options = {};
        }
        Messages.__super__.constructor.call(this, options);
        if (!options.window) {
          throw new Exception('Window is required');
        }
        if (!options.target) {
          throw new Exception('Target is required');
        }
        eventMethod = window.addEventListener ? 'addEventListener' : 'attachEvent';
        eventer = window[eventMethod];
        messageEvent = eventMethod === 'attachEvent' ? 'onmessage' : 'message';
        eventer(messageEvent, this.messageReceiver(this), false);
        this.set('_window', options.window);
        this.set('_target', options.target);
        _ref = Messages.types;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          type = _ref[_i];
          key = toCamelCase("on_" + type + "_callback");
          if (options[key]) {
            this.set(key, options[key]);
          }
        }
      }

      Messages.prototype.sendMessage = function(type, message) {
        this.log("Sending message: " + type + " - " + message);
        return this._window.postMessage({
          type: type,
          message: message
        }, this._target);
      };

      Messages.prototype.messageReceiver = function(self) {
        return function(event) {
          var key;
          self.log("Message received: " + event.data.type + " - " + event.data.message + " from " + event.origin);
          key = toCamelCase("on_" + event.data.type + "_callback");
          if (self[key] && typeof self[key] === 'function') {
            self.log("Runing callback - " + key);
            return self[key](event.data.message);
          }
        };
      };

      _ref = Messages.types;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        type = _ref[_i];
        Messages.prototype[toCamelCase("send_" + type + "_message")] = (function(type) {
          return function(message) {
            return this.sendMessage(type, message);
          };
        })(type);
      }

      return Messages;

    })(BaseLogging);
    ParentClient = (function(_super) {
      __extends(ParentClient, _super);

      function ParentClient(options) {
        var messages;
        if (options == null) {
          options = {};
        }
        ParentClient.__super__.constructor.call(this, options);
        if (!options.iFrame) {
          throw new Exception('iFrame is required');
        }
        if (typeof options.iFrame === 'string') {
          options.iFrame = document.getElementById(options.iFrame);
          if (!options.iFrame) {
            throw new Exception('Invalid iFrame ID');
          }
        }
        messages = new Messages({
          logging: options.logging,
          window: options.iFrame.contentWindow,
          target: options.iFrame.getAttribute('src'),
          onSuccessCallback: options.onSuccessCallback || null,
          onErrorCallback: options.onErrorCallback || null
        });
        options.iFrame.onload = options.iFrameLoadedCallback || null;
        this.set('_iFrame', options.iFrame);
        this.set('messages', messages);
      }

      ParentClient.prototype.start = function() {
        return this.messages.sendStartMessage('start');
      };

      return ParentClient;

    })(BaseLogging);
    return window.Tagasauris = {
      VERSION: '0.0.1',
      ParentClient: ParentClient
    };
  })(window, document);

}).call(this);
