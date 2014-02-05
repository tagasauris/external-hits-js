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

  getOptimal: (value, fn, keyDesc, type='width', forceGet=false) ->
    cacheKey = "_#{keyDesc}_#{type}_#{value}"

    if not @get cacheKey or forceGet
      closest = null
      for item in @items
        if closest is null or fn(item, closest, type, value)
          closest = item
      @set cacheKey, closest

    return @get cacheKey

  getClosestItem: (value, type='width', forceGet=false) ->
    @getOptimal(
      value
      (item, closest, type, width) -> Math.abs(item[type] - value) < Math.abs(closest[type] - value)
      'closestItem'
      type
      forceGet
    )

  getBiggestPossibleItem: (value, type='width', forceGet=false) ->
    @getOptimal(
      value
      (item, closest, type, width) -> value > item[type] > closest[type] or (closest[type] > value and closest[type] > item[type])
      'biggestPossibleItem'
      type
      forceGet
    )
