class ParentClient extends BaseLogging
  constructor: (options={}) ->
    super options

    if not options.iFrame
      throw new Exception 'iFrame is required'

    if typeof(options.iFrame) isnt 'string'
      throw new Exception 'iFrame should be ID selector'

    options.iFrame = document.getElementById options.iFrame
    if not options.iFrame
      throw new Exception 'Invalid iFrame ID'

    notify = new Notify
      logging: options.logging
      window: options.iFrame.contentWindow
      target: options.iFrame.getAttribute 'src'
      onSuccessReceiver: @_onSuccessReceiver(@)
      onStartedReceiver: @_onStartedReceiver(@)
      onErrorReceiver: @_onErrorReceiver(@)

    @set '_iFrame', options.iFrame
    @set 'notify', notify

  start: () ->
    @notify.start()

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