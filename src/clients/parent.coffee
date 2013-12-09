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
      window: options.iFrame.contentWindow
      target: options.iFrame.getAttribute 'src'

    @set '_iFrame', options.iFrame
    @set '_messages', messages
    @set '_onSuccessCallback', options.onSuccessCallback or null
    @set '_onErrorCallback', options.onErrorCallback or null

  start: () ->
