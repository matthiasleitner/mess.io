socketIOHost = "http://"+document.domain+":5002"
push = new Push(socketIOHost);

$(document).ready(function(){
  //jquery ready

  //register device at server
  push.register(null);

  //dynamically display document url for demo
  $("#url").text(document.URL)
})

// push.socket.on('connect', function () {
//  push.spwanConnection()        
//});

push.on("message", function(data){
  console.log("received message: "+ data);
  alert(data)
})

push.on("userKey", function(data){
  $("#user_id").text(data)
  $("#demo").fadeIn(250)
})

push.socket.on("connection_count", function(data){ $(".clients").text(data)});


