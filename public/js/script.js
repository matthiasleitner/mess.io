socketIOHost = "http://"+document.domain+":5002"
console.log(socketIOHost)
push = new Push(socketIOHost);

$(document).ready(function(){
  //jquery ready


  push.register(null);
  $("#url").text(document.URL)
})

// push.socket.on('connect', function () {
//         console.log("connect");
//           push.spwanConnection()
          
//         });

push.on("message", function(data){console.log("test: "+ data)})

push.on("userKey", function(data){
  $("#user_id").text(data)
  $("#demo").fadeIn(250)
})

push.socket.on("connection_count", function(data){ $(".clients").text(data)});


