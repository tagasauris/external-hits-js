class Messages extends BaseLogging
  @types: ['success', 'info', 'warning', 'error', 'start']

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
    eventer messageEvent, @messageReceiver(@), false

    @set '_window', options.window
    @set '_target', options.target

    for type in Messages.types
      key = toCamelCase("on_#{type}_callback")
      if options[key]
        @set key, options[key]

  sendMessage: (type, message) ->
    @log "Sending message: #{type} - #{message}"
    @_window.postMessage type: type, message: message, @_target

  messageReceiver: (self) ->
    (event) ->
      self.log "Message received: #{event.data.type} - #{event.data.message} from #{event.origin}"

      # TODO: check proper event.origin
      key = toCamelCase("on_#{event.data.type}_callback")
      if self[key] and typeof(self[key]) is 'function'
        self.log "Runing callback - #{key}"
        self[key](event.data.message)

  for type in Messages.types
    Messages::[toCamelCase("send_#{type}_message")] = do (type) ->
      (message) ->
        @sendMessage type, message
