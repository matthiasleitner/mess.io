var auto_nconf = require('./auto_conf')

// create main settings configuration
var settings = exports.settings = auto_nconf.createConfiguration('settings', __dirname)
