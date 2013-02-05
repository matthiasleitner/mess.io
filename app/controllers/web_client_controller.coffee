class WebClientController
  constructor: (app, io) ->
    app.get "/", (req, res) =>
      res.render("index", { title: "mess.io | unified push", socket: io.sockets.sockets})

module.exports = WebClientController

