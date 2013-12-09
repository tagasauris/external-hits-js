class Messages extends Base
  constructor: (options={}) ->
    @set 'logging', options.logging or false
    @set '_messageReceivedListener', options.messageReceivedListener or null

    # Browser test for proper listener and event method
    eventMethod  = if win.addEventListener then 'addEventListener' else 'attachEvent'
    eventer      = win[eventMethod]
    messageEvent = if eventMethod is 'attachEvent' then 'onmessage' else 'message'

    # postMessage listener setup
    eventer messageEvent, @messageReceiver(@), false

  log: (message) ->
    if @get 'logging'
      console.log "Tagasauris: #{message}"

  isInIFrame: () ->
    win.location isnt win.parent.location

  sendMessage: (type, message) ->
    @log "Sending message: #{type} - #{message}"
    parent.postMessage type: type, message: message, doc.referrer

  messageReceiver: (self) ->
    (event) ->
      self.log "Message received: #{event.data.type} - #{event.data.message}"

      # TODO:
      #  - check proper event.origin

      if typeof(self._messageReceivedListener) is 'function'
        self._messageReceivedListener event.data.type, event.data.message


  for type in ['success', 'info', 'warning', 'error']
    Messages::[toCamelCase("send_#{type}_message")] = (
      (_type) ->
        (message) ->
          @sendMessage _type, message
    )(type)
