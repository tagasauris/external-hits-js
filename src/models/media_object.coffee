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
