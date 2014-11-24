do (window, document) ->
  if window.Tagasauris
    return

  include "utils.coffee"
  include "exceptions.coffee"
  include "common.coffee"
  include "notify.coffee"
  include "models/base.coffee"
  include "models/media_object.coffee"
  include "models/media_object_item.coffee"
  include "models/score.coffee"
  include "models/transform_result.coffee"
  include "clients/child.coffee"

  window.Tagasauris =
    VERSION: '0.0.1'
    ChildClient: ChildClient
    MediaObject: MediaObject
    MediaObjectItem: MediaObjectItem
    TransformResult: TransformResult
    Score: Score
