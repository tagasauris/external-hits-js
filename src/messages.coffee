class Messages extends BaseLogging
  constructor: (options={}) ->
    super options

    if not options.window
      throw new Exception 'Window is required'

    if not options.target
      throw new Exception 'Target is required'

    @set '_messageReceivedListener', options.messageReceivedListener or null

    # Browser test for proper listener and event method
    eventMethod  = if window.addEventListener then 'addEventListener' else 'attachEvent'
    eventer      = window[eventMethod]
    messageEvent = if eventMethod is 'attachEvent' then 'onmessage' else 'message'

    # postMessage listener setup
    eventer messageEvent, @messageReceiver(@), false
    @set '_window', options.window
    @set '_target', options.target

  sendMessage: (type, message) ->
    @log "Sending message: #{type} - #{message}"
    @_window.postMessage type: type, message: message, @_target

  messageReceiver: (self) ->
    (event) ->
      self.log "Message received: #{event.data.type} - #{event.data.message}"

      # TODO: check proper event.origin
      if typeof(self._messageReceivedListener) is 'function'
        self._messageReceivedListener event.data.type, event.data.message


  for type in ['success', 'info', 'warning', 'error']
    Messages::[toCamelCase("send_#{type}_message")] = do (type) ->
      (message) ->
        @sendMessage type, message
