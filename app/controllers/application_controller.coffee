ResourceController = require("./resource_controller")
Application = require("../models/application")

class ApplicationController extends ResourceController
  constructor: ->
    super(Application)

  create: (req, res) ->
    # check if files are provided
    req.body.apnsCert = req.files.apns_cert.path if req.files.apns_cert.size > 0
    req.body.apnsKey  = req.files.apns_key.path if req.files.apns_key.size > 0

    # TODO remove debug logs
    console.log req.body
    console.log req.query
    console.log req.files

    req.body.accountId = req.session.account

    # create new application from req.body
    app = new Application(req.body)
    console.log app
    app.save (err, app) ->
      if err
        res.json 500,
          error: err
      else
        res.format
          html: ->
            #console.log app
            res.redirect("/profile")
          json: ->
            res.json 200,
              application: app

  show: (req, res) ->
    Application.find req.params.application, (err, app) ->
      if app
        res.format
          html: ->
            res.render "application/show"
              title: "Application #{app.id}"
              app: app
          json: ->
            res.json 200,
              application: app

      else
        res.json 500, err


module.exports = ApplicationController



