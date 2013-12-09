do (window, document) ->
  if win.Tagasauris
    return

  include "utils.coffee"
  include "exceptions.coffee"
  include "common.coffee"
  include "messages.coffee"

  win.Tagasauris =
    VERSION: '0.0.1'
    # Client: Client
    Messages: Messages
