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
      onSuccessCallback: options.onSuccessCallback or null
      onErrorCallback: options.onErrorCallback or null

    options.iFrame.onload = options.iFrameLoadedCallback or null

    @set '_iFrame', options.iFrame
    @set 'messages', messages

  start: () ->
    @messages.sendStartMessage('start')