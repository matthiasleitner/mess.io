_ = require("underscore")

# Super class for a RESRful controller
#
#
class ResourceController
  hierarchy = ["application", "user", "device", "message"]
  constructor: (@klass) ->
    @name = klass.name.toLowerCase()

  # universial index request handler
  #
  #
  index: (req, res) =>
    params = req.params
    assocName = "#{@name}s"

    # is nestest resource
    if _.keys(req.params).length > 1

      # find last step in hierarchy chain
      last_step = null
      for step in hierarchy
        console.log req.params
        if _.contains(_.keys(req.params), step)
          last_step = step

      # find instance
      @_require(last_step).find params[last_step], (err, obj) =>
        # get all objects for association
        obj[assocName] (err, objs) =>
          resp = {}
          resp[assocName] = objs
          res.json resp

    # root resource
    else
      @_require(@name).all (err, objs) =>
        resp = {}
        resp[assocName] = objs
        res.json resp

  # Route new requests to create view
  #
  new: (req, res) =>
    options =
      title: "Create #{@name}"
    @_renderView res, "new", options

  create: (req, res) ->
    obj = new @klass(req.query)
    obj.save (err, app) ->
      if err
        res.json 500,
          error: err
      else
        res.json 200, (
          application: app
        )

  show: (req, res) =>
    @_findObject req, (err, obj) =>
      if obj
        res.format
          html: =>
            options =
              title: "#{@name} #{obj.id} show"
              object: obj
            @_renderView res, "show", options

          json: =>
            data = {}
            data[@name] = obj
            res.json 200, data
      else
        res.json 404

  edit: (req, res) ->
    @_findObject req, (err, obj) =>
      if obj
        options =
          title: "#{klass.name} #{obj.id} edit"
        @_renderView res, "edit", options
      else
        res.json 500

  destroy: (req, res) =>
    console.log req.params

    @klass.find req.params[@name], (err, obj) ->
      if obj
        obj.delete (err, obj) ->
          if obj
            res.json 200, delete: true
          else
            res.json 500, err

      else
        res.json 500, err

  #
  # PRIVATE METHODS
  #

  # helper for rendering views
  _renderView: (res, action, options) ->
    options[@name] = @obj
    res.render "#{@name}/#{action}", options

  # object finder
  _findObject: (req, cb) ->
    if @obj == undefined
      @klass.find req.params[@name], (err, obj) =>
        cb(err, obj)
        @obj = obj if obj
    else
      cb(null, @obj)

  # helper for requiring model
  _require: (model) ->
    require("../models/#{model}")



module.exports = ResourceController




