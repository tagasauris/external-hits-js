class MediaObject extends ModelBase
  _fields: [
    ['id', null],
    ['type', null],
    ['attributes', {}],
    ['items', []],
    ['results', []],
  ]

  deserializeItems: (name, value, options) ->
    (new MediaObjectItem item for item in value)

  deserializeResults: (name, value, options) ->
    results = []
    for result in value
      result.mediaObject = options.id
      results.push new TransformResult(result)
    return results

  createTransformResult: (options={}) ->
    options.mediaObject ?= @get 'id'
    new TransformResult(options)
