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
