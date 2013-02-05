MessageCounter = require("../models/message_counter")
# Controller for demo web client
#
#
class WebClientController
  constructor: (app, io) ->
    app.get "/", (req, res) =>
      MessageCounter.value (err, value) =>
        res.render("index", { title: "mess.io | unified push", socket: io.sockets.sockets, messageCounter: value})

module.exports = WebClientController

