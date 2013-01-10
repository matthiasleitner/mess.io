	require('apns')
    
    APNS.pem  = 'ck.pem'
    # this is the file you just created
    
    APNS.port = 2195 
    # this is also the default. Shouldn't ever have to set this, but just in case Apple goes crazy, you can.

     device_token = '6ee7b0493efd3157815eab98ab14b479be1f1c14b24e5f8bb64565eca688b719'

    APNS.send_notification(device_token, 'Hello iPhone!' )

    APNS.send_notification(device_token, :alert => 'Hello iPhone!', :badge => 1, :sound => 'default')