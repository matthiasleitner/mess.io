var socket = io.connect('http://localhost:3000');

socket.emit('pause', {});

socket.on('news', function () {
  news.emit('woot');
});


socket.on('message', function (msg) {
  alert(msg)
  socket.emit('akn')
});

function registerDevice(){
  socket.emit('register', { "test": "value--"})
}