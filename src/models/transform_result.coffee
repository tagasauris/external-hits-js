class TransformResult extends ModelBase
  _fields: [
    ['id', null],
    ['type', null],
    ['data', {}],
    ['mediaObject', null],
    ['consensusVote', false],
  ]

  setTag: (tag) ->
    @set 'data', tag: tag

  getTag: (tag) ->
    data = @get 'data', {}
    data.tag
