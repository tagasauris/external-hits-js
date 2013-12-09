class Base
  set: (key, value) ->
    @[key] = value

  get: (key, empty=null) ->
    @[key] or empty


class BaseLogging extends Base
  constructor: (options={}) ->
    @set 'logging', options.logging or false

  log: (message) ->
    if @get 'logging'
      console.log "Tagasauris: #{message}"

