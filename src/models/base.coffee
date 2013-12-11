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
