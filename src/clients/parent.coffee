class ParentClient extends BaseLogging
  constructor: (options={}) ->
    super options

    if not options.iFrame
      throw new Exception 'iFrame is required'

    if typeof(options.iFrame) is 'string'
      options.iFrame = document.getElementById(options.iFrame)
      if not options.iFrame
        throw new Exception 'Invalid iFrame ID'

    messages = new Messages
      logging: options.logging
      window: options.iFrame.contentWindow
      target: options.iFrame.getAttribute 'src'
      onSuccessReceiver: @_onSuccessReceiver(@)
      onStartedReceiver: @_onStartedReceiver(@)
      onErrorReceiver: @_onErrorReceiver(@)

    @set '_iFrame', options.iFrame
    @set 'messages', messages

  start: () ->
    @messages.sendStartMessage()

  _onSuccessReceiver: (self) ->
    () ->
      self.onSuccess()

  _onStartedReceiver: (self) ->
    () ->
      self.onStarted()

  _onErrorReceiver: (self) ->
    () ->
      self.onError()

  onSuccess: () ->
    @log new Exception 'onSuccess: Not implemented'

  onStarted: () ->
    @log new Exception 'onStarted: Not implemented'

  onError: () ->
    @log new Exception 'onError: Not implemented'