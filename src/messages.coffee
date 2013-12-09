class Messages extends BaseLogging
  constructor: (options={}) ->
    super options

    @set '_messageReceivedListener', options.messageReceivedListener or null

    # Browser test for proper listener and event method
    eventMethod  = if window.addEventListener then 'addEventListener' else 'attachEvent'
    eventer      = window[eventMethod]
    messageEvent = if eventMethod is 'attachEvent' then 'onmessage' else 'message'

    # postMessage listener setup
    eventer messageEvent, @messageReceiver(@), false

  isInIFrame: () ->
    window.location isnt window.parent.location

  sendMessage: (type, message) ->
    @log "Sending message: #{type} - #{message}"
    parent.postMessage type: type, message: message, doc.referrer

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
