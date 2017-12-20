var express = require('express');
var path = require('path');
var favicon = require('serve-favicon');
var logger = require('morgan');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');

var index = require('./routes/index');
var users = require('./routes/users');
var tasks = require('./routes/tasks');

var app = express();
var mongoose = require('mongoose');
var webSocketServer = require('websocket').server;
var http = require('http');

mongoose.connect('mongodb://localhost/express-app', {useMongoClient: true},
function(err) {
  if(err) {
    console.log('connect error', err);
  } else {
    console.log('connect successful');
  }
});


// WebSocket
var GameRoom = require('../models/GameRoom');
var PlayerList = require('../models/Player');

var webSocketsServerPort = 9090;

// list of currently connected clients (users)
var clients = [ ];
/**
 * HTTP server
 */
var server = http.createServer(function(request, response) {
    // Not important for us. We're writing WebSocket server, not HTTP server
});
server.listen(webSocketsServerPort, function() {
    console.log((new Date()) + " Server is listening on port " + webSocketsServerPort);
});

/**
 * WebSocket server
 */
var wsServer = new webSocketServer({
    httpServer: server
});

wsServer.on('request', function(request) {
    console.log((new Date()) + ' Connection from origin ' + request.origin + '.');
    var connection = request.accept(null, request.origin);
    // we need to know client index to remove them on 'close' event
    var index = clients.push({playerId:-1, roomId: -1, client: connection}) - 1;

    // roomId should be recorded
    var playerId = false;
    var roomId = -1;

    console.log((new Date()) + ' Connection accepted.');
    // user sent some message
    connection.on('message', function(message) {
      //console.log(index);
      if (message.type === 'utf8') { // accept only text
        //console.log(message.utf8Data);
        //console.log(JSON.parse(message.utf8Data));
        /*
        if (playerId === false) { //  first message sent by clients is the roomId
          playerId = Number(message.utf8Data);
          //console.log("playerId: " + message.utf8Data);
          console.log("playerId: " + playerId);
          clients[index].playerId = playerId;
        } else {
          */
          console.log((new Date()) + ' Received Message ' + ': ' + message.utf8Data);

          // message object
          var obj = {
              time: (new Date()).getTime(),
              text: message.utf8Data,
              //author: userName,
          };

          // broadcast message to all connected clients
          var json = JSON.stringify({ type:'message', data: obj });
          for (var i=0; i < clients.length; i++) {
            if(clients[i].roomId == roomId) { // only send message to clients in the same room
              clients[i].client.sendUTF(json);
            }
          }
        //}
      } else {

        //console.log(JSON.parse(message.binaryData));
        var dic = JSON.parse(message.binaryData);

        switch (dic.type)
        {
          case "signIn": {
            playerId = dic.playerId;
            clients[index].playerId = playerId;
            console.log("webSocketServer: player signIn with id: " + playerId);
            break;
          }
          case "joinGameRoom": {
            roomId = dic.roomId;
            clients[index].roomId = roomId;
            for (var i=0; i < clients.length; i++) {
              if(i != index && clients[i].roomId == roomId) { // only send message to other clients in the same room
                clients[i].client.sendUTF(JSON.stringify(dic));
              }
            }
            break;
          }
          case "exitGameRoom": {
            roomId = dic.roomId;
            clients[index].roomId = -1;
            for (var i=0; i < clients.length; i++) {
              if(i != index && clients[i].roomId == roomId) { // only send message to other clients in the same room
                clients[i].client.sendUTF(JSON.stringify(dic));
              }
            }
            break;
          }
          case "chattingMessage": {
            for (var i=0; i < clients.length; i++) {
              if(clients[i].roomId == roomId) { // only send message to clients in the same room
                clients[i].client.sendUTF(JSON.stringify(dic));
              }
            }
            break;
          }
          case "changeGameState": {
            for (var i=0; i < clients.length; i++) {
              if(clients[i].roomId == roomId) { // only send message to clients in the same room
                //console.log("send changeGameState message to player with index: " + i);
                clients[i].client.sendUTF(JSON.stringify(dic));
              }
            }
            break;
          }
          case "sendDrawingBoard": {
            for (var i=0; i < clients.length; i++) {
              if(i != index && clients[i].roomId == roomId) { // only send message to other clients in the same room
                clients[i].client.sendUTF(JSON.stringify(dic));
              }
            }
            break;
          }
          case "sendAnswer": {
            for (var i=0; i < clients.length; i++) {
              if(clients[i].roomId == roomId) { // only send message to clients in the same room
                clients[i].client.sendUTF(JSON.stringify(dic));
              }
            }
            break;
          }
          default: {
            console.log("unknown message type received by WebSocketServer.");
            break;
          }
        }
        if (dic.type != "sendDrawingBoard") { // we don't want too many sendDrawingBoard messages occupying the screen.
          console.log(dic);
          console.log(dic.type);
          console.log("sender socket playerId: " + clients[index].playerId);
          console.log("sender socket roomId: " + clients[index].roomId);
          console.log("sender socket current roomId: " + roomId);
        }
      }
    });

    // user disconnected
    connection.on('close', function(connection) {
      console.log((new Date()) + " Peer " + connection.remoteAddress + " disconnected.");
      // remove user from the list of connected clients
      clients.splice(index, 1);
    });
});


// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'ejs');

// uncomment after placing your favicon in /public
//app.use(favicon(path.join(__dirname, 'public', 'favicon.ico')));
app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

app.use('/', index);
app.use('/users', users);
app.use('/tasks', tasks);

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  var err = new Error('Not Found');
  err.status = 404;
  next(err);
});

// error handler
app.use(function(err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render('error');
});

module.exports = app;
