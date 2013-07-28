MessageCounter = require("../models/message_counter")
Account = require("../models/account")
Application = require("../models/application")
async = require("async")

# Controller for demo web client
#
#
class WebClientController

  emailPattern = /// ^ # begin of line
   ([\w.-]+)         # one or more letters, numbers, _ . or -
   @                 # followed by an @ sign
   ([\w.-]+)         # then one or more letters, numbers, _ . or -
   \.                # followed by a period
   ([a-zA-Z.]{2,6})  # followed by 2 to 6 letters or periods
   $ ///i            # end of line and ignore case

  loadCount: (application, cb) =>
    #get number of users for application
    application.usersCount (err, count) =>
      application.set("usersCount", count)

      supportedPlatforms = []

      # check if application supports plattform
      if application.get("apnsCert")
        supportedPlatforms.push("iOS")

      if application.get("gcmProjectId")
        supportedPlatforms.push("Android")

      supportedPlatforms.push("Web")

      application.set("supportedPlatforms", supportedPlatforms)

      application.devicesCount (err, count) =>
        application.set("devicesCount", count)
        cb(err, application)

  constructor: (app, io) ->
    app.get "/", (req, res) =>
      console.log req.session
      MessageCounter.value (err, value) =>
        res.render "index",
          title: "mess.io | unified push",
          socket: io.sockets.sockets,
          messageCounter: value,
          loggedIn: req.session.account

    app.get "/profile", (req, res) =>
      if req.session.account
        Account.find req.session.account, (err, account) =>
          account.applications (err, applications) =>
            async.map applications, @loadCount, (err, response) =>
              res.render "profile",
                account: account,
                title: "mess.io | unified push",
                loggedIn: req.session.account,
                applications: applications
      else
        res.redirect "/"

    app.post "/login", (req, res) =>
      Account.findBy "email", req.body.email, (err, account) =>
        if account
          account.verifyPassword req.body.password, (err, login) =>
            if login
              req.session.account = account.get("id")
            res.send
              success: login
        else
          res.send
            success: false

    app.get "/logout", (req, res) =>
      delete req.session.account
      res.redirect "/"

    app.post "/signup", (req, res) =>
      form = req.body

      # validate presene of form values
      unless form.name &&
             form.email &&
             form.password &&
             form.password_confirmation
        res.send
          success: false
          reason: "Incomplete form"
        return

      # check matching password confirmation
      unless form.password == form.password_confirmation
        res.send
          success: false
          reason: "Passwords don't match"
        return

      # check email regex
      unless form.email.match emailPattern
        res.send
          success: false
          reason: "Email format invalid"
        return

      # check for existing account
      Account.findBy "email", form.email, (err, account) =>
        if account
          res.send
            success: false
            reason: "Email already taken"
          return

        # create account
        account = new Account
          name: req.body.name
          email: req.body.email

        # assign password
        account.setPassword req.body.password, (err, hash) =>
          # save
          account.save (err, account) ->
            # return new account id
            req.session.account = account.get("id")
            res.send
              success: true


module.exports = WebClientController

