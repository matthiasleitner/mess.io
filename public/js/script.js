var socket = io.connect('http://localhost:3000');

socket.emit('pause', {});

socket.on('news', function () {
  news.emit('woot');
});

socket.on('spwanConnection', function (data){


});

socket.on('socketList', function (data){

	console.log(data);

});



socket.on('message', function (msg) {
  alert(msg)
  socket.emit('akn')
});

function registerDevice(){
  socket.emit('register', { "test": "value--"})
}

function requestSocketList(){
	socket.emit('socketList', function (data) {
  		console.log(data); // data will be 'woot'
	});
}