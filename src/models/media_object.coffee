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

  getOptimal: (value, dimension, eval_func, filter_func) ->
    if not filter_func
      filter_func = () -> true

    closest = null
    for item in @items
      if filter_func(item)
        if closest is null or eval_func(item, closest, dimension, value)
          closest = item

    return closest

  getClosestItem: (value, dimension='width', filter_func) ->
    @getOptimal(
      value
      dimension
      (item, closest, dimension, value) -> Math.abs(item[dimension] - value) < Math.abs(closest[dimension] - value)
      filter_func
    )

  getBiggestPossibleItem: (value, dimension='width', filter_func) ->
    @getOptimal(
      value
      dimension
      (item, closest, dimension, value) -> value > item[dimension] > closest[dimension] or (closest[dimension] > value and closest[dimension] > item[dimension])
      filter_func
    )

  isRectoVerso: () ->
    recto = false
    verso = false
    for item in @items
      if item.code?
        if item.code == 'recto'
          recto = true
          return true if verso
        else if item.code == 'verso'
          verso = true
          return true if recto
    return recto and verso
