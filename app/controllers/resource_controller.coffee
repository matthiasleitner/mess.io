class ResourceController
  
  @index: (req, res) ->
    Application.all (err, apps)->
      if err
        res.json 500, 
          error: err
      else
        res.json (
          applications: apps
        )

  @new: (req, res) ->
    res.send "new user"
    
  @create: (req, res) ->

    app = new Application(req.query)

    app.save (err, app) ->
      if err
        res.json 500, 
          error: err
      else
        res.json 200, (
          application: app
        )

  @show: (req, res) ->
    Application.find req.params.application, (err, app) ->
      if app
        res.json 200, (
          application: app
        )

      else
        res.json 500, err

  @edit = (req, res) ->
    res.send "edit user " + req.params.user

  @update: (req, res) ->
    res.send "update user " + req.params.user

  @destroy: (req, res) ->
    User.find req.params.user, (err, user) ->
      res.send "delete user " + user.delete (err, reps) ->
        console.log err
        console.log reps
      



