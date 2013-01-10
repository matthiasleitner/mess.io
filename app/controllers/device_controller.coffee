exports.index = (req, res) ->
  req.params.user
  res.send "device index"

exports.new = (req, res) ->
  res.send "new device"
  
exports.create = (req, res) ->
  res.send "create device"

exports.show = (req, res) ->
  res.send "show device " + req.params.device

exports.edit = (req, res) ->
  res.send "edit device " + req.params.device

exports.update = (req, res) ->
  res.send "update device " + req.params.device

exports.destroy = (req, res) ->
  res.send "destroy device " + req.params.device

