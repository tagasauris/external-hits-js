class ModelBase extends Base
  _fields: []

  constructor: (options={}) ->
    options = @toObject(options)
    for [name, initial] in @_fields
      value = options[name]
      value ?= initial
      key = toCamelCase("deserialize_#{name}")
      if @[key] and typeof(@[key]) is 'function'
        value = @[key] name, value, options
      @set name, value

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
