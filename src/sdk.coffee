((win, doc) ->
  if win.Tagasauris
    return


  urlEncode = (params) ->
    tail = []
    if params instanceof Array
      for param in params
          if param instanceof Array && param.length > 1
              tail.push "#{param[0]}=#{encodeURIComponent(param[1])}"
    else
      for key, value of params
        if value instanceof Array
          for v in value
            tail.push "#{key}=#{encodeURIComponent(v)}"
        else
          tail.push "#{key}=#{encodeURIComponent(value)}"
    return tail.join '&'


  # From Underscore
  toCamelCase = (text) ->
    text.replace /(_[a-z])/g, ($1) -> $1.toUpperCase().replace('_', '')


  # From CamelCase
  toUnderscore = (text) ->
    text.replace /([A-Z])/g, ($1) -> '_' + $1.toLowerCase()


  class Exception
    constructor: (@message) ->
      @name = 'Exception'

    toString: () ->
      @message


  class Base
    set: (key, value) ->
      @[key] = value

    get: (key, empty=null) ->
      @[key] or empty


  class Client extends Base
    constructor: (options={}) ->
      @set 'logging', options.logging or false

      if not options.state
        throw new Exception 'State is required'

      if not options.sourceUrl
        throw new Exception 'Source URL is required'

      if not options.resultsUrl
        throw new Exception 'Results URL is required'

      @set 'state', options.state
      @set 'sourceUrl', options.sourceUrl
      @set 'resultsUrl', options.resultsUrl
      @set '_requestTimeout', options.requestTimeout or 30000
      @set '_requestTimeoutCallback', options.requestTimeoutCallback or null

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
        if typeof(self._requestTimeoutCallback) is 'function'
          self._requestTimeoutCallback()
      timeout = setTimeout timeoutCallback, @_requestTimeout

      self.log "XHR Request Calling #{method} - #{url}"
      xhr.send body

    log: (message) ->
      if @get 'logging'
        console.log "Tagasauris: #{message}"


  class Messages extends Base
    constructor: (options={}) ->
      @set 'logging', options.logging or false
      @set '_messageReceivedCallback', options.messageReceivedCallback or null

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

        if typeof(self._messageReceivedCallback) is 'function'
          self._messageReceivedCallback event.data.type, event.data.message


    for type in ['success', 'info', 'warning', 'error']
      Messages::[toCamelCase("send_#{type}_message")] = (
        (_type) ->
          (message) ->
            @sendMessage _type, message
      )(type)


  class ModelBase extends Base
    _fields: []

    constructor: (options={}) ->
      options = @toObject(options)
      for [name, initial] in @_fields
        options[name] ?= initial
        value = @deserialize name, options[name], options
        @set name, value

    deserialize: (key, value, options) ->
      value

    toObject: (data) ->
      tmp = {}
      for k, v of data
          tmp[toCamelCase(k)] = v
      return tmp

    toJSON: () ->
      tmp = {}
      for k, v of @
        if v isnt null and k.substring(0, 1) isnt '_'
          tmp[toUnderscore(k)] = v
      return tmp


  class MediaObjectItem extends ModelBase
    _fields: [
      ['id', null],
      ['type', null],
      ['src', null],
      ['width', 0],
      ['height', 0],
    ]


  class MediaObject extends ModelBase
    _fields: [
      ['id', null],
      ['type', null],
      ['attributes', {}],
      ['items', []],
      ['results', []],
    ]

    deserialize: (key, value, options) ->
      if key is 'items'
        value = (new MediaObjectItem item for item in value)

      if key is 'results'
        results = []
        for result in value
          result.mediaObject = options.id
          results.push new TransformResult(result)
        value = results

      return value

    createTransformResult: (options={}) ->
      options.mediaObject ?= @get 'id'
      new TransformResult(options)


  class TransformResult extends ModelBase
    _fields: [
      ['id', null],
      ['type', null],
      ['data', {}],
      ['mediaObject', null],
    ]

    setTag: (tag) ->
      @set 'data', tag: tag

    getTag: (tag) ->
      data = @get 'data', {}
      data.tag


  class Score extends ModelBase
    _fields: [
      ['id', null],
      ['type', null],
      ['value', null],
      ['semanticValue', null],
      ['transformResult', null],
    ]


  win.Tagasauris =
    SDK_VERSION: '0.0.1'
    Client: Client
    MediaObject: MediaObject
    MediaObjectItem: MediaObjectItem
    TransformResult: TransformResult
    Score: Score
    Messages: Messages


)(window, document)