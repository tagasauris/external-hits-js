class Exception
  constructor: (@message) ->
    @name = 'Exception'

  toString: () ->
    @message
