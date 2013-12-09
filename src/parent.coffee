do (window, document) ->
  if window.Tagasauris
    return

  include "utils.coffee"
  include "exceptions.coffee"
  include "common.coffee"
  include "messages.coffee"
  include "clients/parent.coffee"

  window.Tagasauris =
    VERSION: '0.0.1'
    Client: ParentClient
