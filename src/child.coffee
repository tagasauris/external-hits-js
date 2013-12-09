do (window, document) ->
  if win.Tagasauris
    return

  include "utils.coffee"
  include "exceptions.coffee"
  include "common.coffee"
  include "messages.coffee"
  include "models/base.coffee"
  include "models/media_object.coffee"
  include "models/media_object_item.coffee"
  include "models/score.coffee"
  include "models/transform_result.coffee"

  win.Tagasauris =
    VERSION: '0.0.1'
    Client: Client
    MediaObject: MediaObject
    MediaObjectItem: MediaObjectItem
    TransformResult: TransformResult
    Score: Score
    Messages: Messages
