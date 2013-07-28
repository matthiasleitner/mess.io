
push = new Mess("mJykLErTTaeEGSeGIsw6CgUQSMekSqcq", 355);

$(document).ready(function(){
  //dynamically display document url for demo
  $("#url").text(document.URL)


  $("#signup-button").click(function(event){
    event.preventDefault();

    password = $("#signupPassword").val()
    password_confirmation = $ ("#signupPasswordConfirmation").val()
    name = $("#signupName").val()
    email = $("#signupEmail").val()

    if (password == password_confirmation){
      if (password.length >= 6){
        console.log($("#signupName").val())

        $.ajax({
          type: "POST",
          url: "/signup",
          data: {name: name, password: password, password_confirmation: password_confirmation, email: email},
          success: function(data){
            if(data.success){
              window.location = "profile"
             } else {
              $("#signup-modal-alert").html('<div class="alert alert-error"><strong>Error: </strong>' + data.reason + '</div>')
            }
          }
        });
      } else {
         $("#signup-modal-alert").html('<div class="alert alert-error"><strong>Password to short!</strong> Please enter at least 6 digits</div>')
      }
    } else {
      $("#signup-modal-alert").html('<div class="alert alert-error"><strong>Password missmatch!</strong> Please check the passwords you have entered</div>')
    }
  })

  $("#login-button").click(function(event){
    email = $("#loginEmail").val()
    password = $("#loginPassword").val()
    event.preventDefault();

    console.log($("#signupName").val())

    if(email.length > 0 && password.length > 0){
      $.ajax({
        type: "POST",
        url: "/login",
        data: {email: email, password: password},
        success: function(data){
         if(data.success){
            window.location = "profile"
          } else {
            $("#login-modal-alert").html('<div class="alert alert-error"><strong>Login failed!</strong> Please check your credentials</div>')
          }
        }
      });
    } else {
      $("#login-modal-alert").html('<div class="alert alert-error"><strong>Incomplete data!</strong> Enter email and password</div>')
    }

  })
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

push.on("sent_message_count", function(data){
  $(".messages").text(data)
})

push.on("connection_count", function(data){
  $(".clients").text(data)
});


