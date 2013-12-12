# encodes URL query
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


parseUri = (url) ->
  # TODO: support for arrays

  result = {}
  parser = document.createElement 'a'
  parser.href = url

  for key in ['protocol', 'hostname', 'host', 'pathname', 'port', 'search', 'hash', 'href']
    result[key] = parser[key]

    if key is 'search'
      search = {}

      if result[key]
        value = result[key]
        if value.indexOf('?') is 0
          value = value.substring 1

        for part in value.split '&'
          [_key, _value] = part.split '='
          search[_key] = decodeURIComponent _value

      result[key] = search

  result.toString = () -> parser.href
  result.requestUri = "#{result.pathname}#{result.search}"

  return result


# From Underscore
toCamelCase = (text) ->
  text.replace /(_[a-z])/g, ($1) -> $1.toUpperCase().replace('_', '')


# From CamelCase
toUnderscore = (text) ->
  text.replace /([A-Z])/g, ($1) -> '_' + $1.toLowerCase()
