class ChildClient extends BaseLogging
  constructor: (options={}) ->
    super options

    if not options.state
      throw new Exception 'State is required'

    if not options.sourceUrl
      throw new Exception 'Source URL is required'

    if not options.resultsUrl
      throw new Exception 'Results URL is required'

    messages = new Messages
      logging: options.logging
      window: parent
      target: document.referrer
      onStartReceiver: @_onStartReceiver(@)

    @set 'state', options.state
    @set 'sourceUrl', options.sourceUrl
    @set 'resultsUrl', options.resultsUrl
    @set 'messages', messages
    @set 'requestTimeout', options.requestTimeout or 30000

  getData: (options, callback) ->
    if typeof(options) is 'function'
      callback = options
      options = {}

    options.endpoint ?= @get 'sourceUrl'

    @request options, (err, response)->
      return callback err, response if err
      response.data = (new MediaObject mo for mo in response.data)
      callback null, response

  saveData: (options, callback) ->
    if typeof(options) is 'function'
      callback = options
      options = {}

    options.endpoint ?= @get 'resultsUrl'
    options.method   ?= 'POST'

    @request options, (err, response)->
      return callback err, response if err
      callback null, response

  request: (options, callback) ->
    self     = this
    method   = options.method or 'GET'
    endpoint = options.endpoint or ''
    body     = JSON.stringify options.body or {}
    qs       = options.qs or {}
    url      = endpoint

    # Auth
    if @get 'state'
      qs.state = @get 'state'

    # Query
    # Workaround for:
    # https://github.com/10clouds/tagasauris/blob/master/tagasauris/data/middleware.py#L10
    qs.cookie_fix = 0
    encodedParams = urlEncode qs
    if encodedParams
      url += '?' + encodedParams

    xhr = new XMLHttpRequest()
    xhr.open method, url, true

    if options.body
      xhr.setRequestHeader 'Content-Type', 'application/json'
      xhr.setRequestHeader 'Accept', 'application/json'

    xhr.onerror = (response) ->
      clearTimeout timeout
      self.log "XHR Request Error #{method} - #{url}"

      if typeof(callback) is 'function'
        callback true, response

    xhr.onload = (response) ->
      clearTimeout timeout
      self.log "XHR Request Success #{method} - #{url}"

      try
        response = JSON.parse xhr.responseText
      catch err
        console.error err

      if typeof(callback) is 'function'
        callback err or false, response

    timeoutCallback = () ->
      xhr.abort()
      self.log "XHR Request Timeout #{method} - #{url}"
      self.onRequestTimeout()
    timeout = setTimeout timeoutCallback, @requestTimeout

    self.log "XHR Request Calling #{method} - #{url}"
    xhr.send body

  success: () ->
    @messages.sendSuccessMessage()

  error: (err) ->
    @messages.sendErrorMessage err.message

  _onStartReceiver: (self) ->
    () ->
      self.messages.sendStartedMessage()
      self.onStart()

  onStart: () ->
    @log new Exception 'onStart: Not implemented'

  onRequestTimeout: () ->
    @error new Exception 'XHR Request Timeout'
