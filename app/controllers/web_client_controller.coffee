class WebClientController
  constructor: (app) ->
    app.get "/", (req, res) ->
      res.render("index", { title: "web client" })

module.exports = WebClientController