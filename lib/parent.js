(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  (function(window, document) {
    var Base, BaseLogging, Exception, Notify, ParentClient, toCamelCase, toUnderscore, urlEncode;
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
          return console.log("Tagasauris." + this.constructor.name + ": " + message);
        }
      };

      return BaseLogging;

    })(Base);
    Notify = (function(_super) {
      var type, _i, _len, _ref;

      __extends(Notify, _super);

      Notify.types = ['start', 'started', 'success', 'error'];

      function Notify(options) {
        var eventMethod, eventer, key, messageEvent, type, _i, _len, _ref;
        if (options == null) {
          options = {};
        }
        Notify.__super__.constructor.call(this, options);
        if (!options.window) {
          throw new Exception('Window is required');
        }
        if (!options.target) {
          throw new Exception('Target is required');
        }
        eventMethod = window.addEventListener ? 'addEventListener' : 'attachEvent';
        eventer = window[eventMethod];
        messageEvent = eventMethod === 'attachEvent' ? 'onmessage' : 'message';
        eventer(messageEvent, this.notifyReceiver(this), false);
        this.set('_window', options.window);
        this.set('_target', options.target);
        _ref = Notify.types;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          type = _ref[_i];
          key = toCamelCase("on_" + type + "_receiver");
          if (options[key]) {
            this.set(key, options[key]);
          }
        }
      }

      Notify.prototype.sendNotify = function(type, notify) {
        if (notify == null) {
          notify = null;
        }
        this.log("Sending " + type);
        return this._window.postMessage({
          type: type,
          notify: notify
        }, this._target);
      };

      Notify.prototype.notifyReceiver = function(self) {
        return function(event) {
          var key;
          self.log("Received " + event.data.type + " from " + event.origin);
          if (self._target.indexOf(event.origin) !== 0) {
            return self.log(new Exception('Invalid notify origin'));
          }
          key = toCamelCase("on_" + event.data.type + "_receiver");
          if (self[key] && typeof self[key] === 'function') {
            self.log("Runing " + key);
            return self[key](event.data.notify);
          }
        };
      };

      _ref = Notify.types;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        type = _ref[_i];
        Notify.prototype[type] = (function(type) {
          return function(notify) {
            return this.sendNotify(type, notify);
          };
        })(type);
      }

      return Notify;

    })(BaseLogging);
    ParentClient = (function(_super) {
      __extends(ParentClient, _super);

      function ParentClient(options) {
        var notify;
        if (options == null) {
          options = {};
        }
        ParentClient.__super__.constructor.call(this, options);
        if (!options.iFrame) {
          throw new Exception('iFrame is required');
        }
        if (typeof options.iFrame !== 'string') {
          throw new Exception('iFrame should be ID selector');
        }
        options.iFrame = document.getElementById(options.iFrame);
        if (!options.iFrame) {
          throw new Exception('Invalid iFrame ID');
        }
        notify = new Notify({
          logging: options.logging,
          window: options.iFrame.contentWindow,
          target: options.iFrame.getAttribute('src'),
          onSuccessReceiver: this._onSuccessReceiver(this),
          onStartedReceiver: this._onStartedReceiver(this),
          onErrorReceiver: this._onErrorReceiver(this)
        });
        this.set('_iFrame', options.iFrame);
        this.set('notify', notify);
      }

      ParentClient.prototype.start = function() {
        return this.notify.start();
      };

      ParentClient.prototype._onSuccessReceiver = function(self) {
        return function() {
          return self.onSuccess();
        };
      };

      ParentClient.prototype._onStartedReceiver = function(self) {
        return function() {
          return self.onStarted();
        };
      };

      ParentClient.prototype._onErrorReceiver = function(self) {
        return function() {
          return self.onError();
        };
      };

      ParentClient.prototype.onSuccess = function() {
        return this.log(new Exception('onSuccess: Not implemented'));
      };

      ParentClient.prototype.onStarted = function() {
        return this.log(new Exception('onStarted: Not implemented'));
      };

      ParentClient.prototype.onError = function() {
        return this.log(new Exception('onError: Not implemented'));
      };

      return ParentClient;

    })(BaseLogging);
    return window.Tagasauris = {
      VERSION: '0.0.1',
      ParentClient: ParentClient
    };
  })(window, document);

}).call(this);
