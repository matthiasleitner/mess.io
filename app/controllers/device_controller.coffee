Device = require("../models/device")
ResourceController = require("./resource_controller")


class DeviceController extends ResourceController
  constructor: ->
    super(Device)

  new: (req, res) ->
    res.render "device/new", 
      title: "Create device"
      user: req.params.user
      application: req.params.application
  
  create: (req, res) ->
    body = req.body

    device = new Device
      name: req.body.name
      applicationId: req.params.application
      userId: req.params.user
      apnsToken: body.apns_token
      gcmToken: body.gcm_token
    
    device.save (err, device) ->
      res.json 200, device  

module.exports = DeviceController

