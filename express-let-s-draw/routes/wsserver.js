var express = require('express');
var app = express();
var expressWs = require('express-ws')(app);
var util = require('util');
app.use(express.static('./static'));
app.ws('/ws', function(ws, req) {
  util.inspect(ws);
  ws.on('message', function(msg) {
    console.log('_message');
    console.log(msg);
    ws.send('echo:' + msg);
  });
})
app.listen(9090);  
