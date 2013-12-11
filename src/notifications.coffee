class Notifications extends BaseLogging
  @types: ['start', 'started', 'success', 'error']

  constructor: (options={}) ->
    super options

    if not options.window
      throw new Exception 'Window is required'

    if not options.target
      throw new Exception 'Target is required'

    # Browser test for proper listener and event method
    eventMethod  = if window.addEventListener then 'addEventListener' else 'attachEvent'
    eventer      = window[eventMethod]
    messageEvent = if eventMethod is 'attachEvent' then 'onmessage' else 'message'

    # postMessage listener setup
    eventer messageEvent, @notificationReceiver(@), false

    @set '_window', options.window
    @set '_target', options.target

    for type in Notifications.types
      key = toCamelCase("on_#{type}_receiver")
      if options[key]
        @set key, options[key]

  sendNotification: (type, notification='') ->
    @log "Sending #{type}"
    @_window.postMessage type: type, notification: notification, @_target

  notificationReceiver: (self) ->
    (event) ->
      self.log "Received #{event.data.type} from #{event.origin}"

      if self._target.indexOf(event.origin) isnt 0
        return self.log new Exception 'Invalid notification origin'

      key = toCamelCase("on_#{event.data.type}_receiver")
      if self[key] and typeof(self[key]) is 'function'
        self.log "Runing receiver #{key}"
        self[key](event.data.notification)

  for type in Notifications.types
    Notifications::[toCamelCase("send_#{type}")] = do (type) ->
      (notification) ->
        @sendNotification type, notification
