var apns = require('apn');

var options = {
    cert: 'cert.pem',                 /* Certificate file path */
    certData: null,                   /* String or Buffer containing certificate data, if supplied uses this instead of cert file path */
    key:  'key.pem',                  /* Key file path */
    keyData: null,                    /* String or Buffer containing key data, as certData */
    ca: null,                         /* String or Buffer of CA data to use for the TLS connection */
    pfx: null,                        /* File path for private key, certificate and CA certs in PFX or PKCS12 format. If supplied will be used instead of certificate and key above */
    pfxData: null,                    /* PFX or PKCS12 format data containing the private key, certificate and CA certs. If supplied will be used instead of loading from disk. */
    gateway: 'gateway.sandbox.push.apple.com',/* gateway address */
    port: 2195,                       /* gateway port */
    rejectUnauthorized: true,         /* Value of rejectUnauthorized property to be passed through to tls.connect() */
    enhanced: true,                   /* enable enhanced format */
    errorCallback: undefined,         /* Callback when error occurs function(err,notification) */
    cacheLength: 100,                 /* Number of notifications to cache for error purposes */
    autoAdjustCache: true,            /* Whether the cache should grow in response to messages being lost after errors. */
    connectionTimeout: 0              /* The duration the socket should stay alive with no activity in milliseconds. 0 = Disabled. */
};

function errCallback(){

}


var apnsConnection = new apns.Connection(options);

var token = "6ee7b0493efd3157815eab98ab14b479be1f1c14b24e5f8bb64565eca688b719"
var myDevice = new apns.Device(token);
var note = new apns.Notification();

note.expiry = Math.floor(Date.now() / 1000) + 3600; // Expires 1 hour from now.
note.badge = 5;
note.alert = "You have a new message- yeag2!";
note.payload = {'messageFrom': 'Caroline'};
note.device = myDevice;

apnsConnection.sendNotification(note);
apnsConnection.sendNotification(note);