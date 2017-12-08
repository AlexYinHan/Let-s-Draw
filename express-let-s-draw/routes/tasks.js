var express = require('express');
var router = express.Router();
var Question = require('../models/Question');
var GameRoom = require('../models/GameRoom');
var PlayerList = require('../models/Player');

router.get('/', function(req, res, next) {
  res.send("This is a response to get.");
});

router.get('/playerRole', function(req, res, next) {
  res.send("Guesser");
});

router.get('/getAllRooms', function(req, res, next) {
  GameRoom.find({}, function(err, tasks){
		if(err){
			return res.status(400).send("err in get /getAllRooms");
		}else{
			console.log(tasks);
			return res.status(200).json(tasks);
		}
	});

});

router.get('/getAllPlayers', function(req, res, next) {
  PlayerList.find({}, function(err, tasks){
		if(err){
			return res.status(400).send("err in get /getAllPlayers");
		}else{
			console.log(tasks);
			return res.status(200).json(tasks);
		}
	});

});

router.post('/signIn', function(req, res, next) {
  var playerName = req.query.userName;

  var isThisIdExist = 0;
  do {
    var randomId = 1 + Math.round(Math.random()*1000); // 1 ~ 1001
    PlayerList.find({Id: randomId}, function(err, players) {
        if (players.length > 0) {
          isThisIdExist = 1;
        }
    });
  }while(isThisIdExist == 1);

  PlayerList.create({name: playerName, Id: randomId}, function(err){
    if (err) {
      return res.status(400).send("err in post /signIn");
    } else {

      return res.status(200).json([{playerId: randomId}]);
    }
  });
});

router.delete('/signOut', function(req, res, next) {
  var playerId = req.query.id;

  PlayerList.remove({Id: playerId}, function(err){
    if (err) {
      return res.status(400).send("err in post /signIn");
    } else {

      return res.status(200).json([{playerId: playerId}]);
    }
  });
});

router.post('/createRoom', function(req, res, next) {

  var isThisIdExist = 0;
  do {
    var randomId = 1000 + Math.round(Math.random()*999); // 1000 ~ 1999
    GameRoom.find({roomId: randomId}, function(err, players) {
        if (players.length > 0) {
          isThisIdExist = 1;
        }
    });
  }while(isThisIdExist == 1);

  GameRoom.create({roomId: randomId}, function(err){
		if (err) {
      console.log(error);
			return res.status(400).send("err in createRoom /get");
		} else {
      console.log("create room.");
      console.log({roomId: randomId});
			return res.status(200).json([{roomId: randomId}]);
		}
	});

});

router.delete('/deleteRoom', function(req, res, next) {
  var roomID = req.query.roomId;

  GameRoom.remove({roomId: roomID}, function(error) {
    if(error) {
        console.log(error);
        return res.status(400).send("err in delete /task");
    } else {
        return res.status(200).json([{roomId: roomID}]);
        console.log('delete ok!');
    }
  });

});

router.post('/getPlayersInRoom', function(req, res, next) {
  var roomID = req.query.roomId;

  GameRoom.find({roomId: roomID}, function(err, tasks){
		if (err) {
      console.log(error);
			return res.status(400).send("err in get /getPlayersInRoom");
		} else {
      if (tasks.length < 1) {
        return res.status(400).send("No room found with id " + roomID);
      } else {
        console.log("getPlayersInRoom room.");
        console.log(tasks[0].players);
        return res.status(200).json(tasks[0].players);
        /*
        PlayerList.find({Id: tasks[0].players}, function(err, players){
          if (err) {
            console.log(error);
      			return res.status(400).send("err in get /getPlayersInRoom");
      		} else {
            return res.status(200).json(players);
          }
        });
        */
      }
		}
	});
});

router.put('/addPlayerToRoom', function(req, res, next) {
  var roomID = req.query.roomId;
  var playerId = req.query.playerId;

  GameRoom.update({roomId: roomID}, {$push : {players: {id: playerId}}}, function(err, tasks){
		if (err) {
      console.log(error);
			return res.status(400).send("err in post /addPlayerToRoom");
		} else {
      console.log("add player with id " + playerId + " to room with roomId " + roomID);
			return res.status(200).json([tasks]);
		}
	});

});

router.put('/removePlayerFromRoom', function(req, res, next) {
  var roomID = req.query.roomId;
  var playerId = req.query.playerId;

  GameRoom.update({roomId: roomID}, {$pull : {players: {id: playerId}}}, function(err, tasks){
		if (err) {
      console.log(error);
			return res.status(400).send("err in post /removePlayerFromRoom");
		} else {
      console.log("remove player with id " + playerId + " to room with roomId " + roomID);
			return res.status(200).json([tasks]);
		}
	});

});

router.post('/sendChattingMessageInRoom', function(req, res, next) {
  var roomID = req.query.roomId;
  var playerName = req.query.playerName;
  var message = req.query.content;

  GameRoom.update({roomId: roomID}, {chatContent: message}, function(err, tasks){
		if (err) {
      console.log(error);
			return res.status(400).send("err in post /sendChattingMessage");
		} else {
      console.log("sendChattingMessage to room " + roomID);
      console.log(message);

      PlayerList.update({roomNumber: roomID}, {isNotified: 0});
			return res.status(200).json([tasks]);
		}
	});
});

router.post('/getChattingMessageInRoom', function(req, res, next) {
  var roomID = req.query.roomId;
  var playerName = req.query.playerName;

  PlayerList.find({name: playerName}, function(err, players){//find user check isNotified state
    if (err) {
      console.log(error);
      return res.send("");
    } else {
      console.log(players);
      if (players.length < 1 || players[0].isNotified == 1) {
        return res.send("");
      } else {
        GameRoom.find({roomId: roomID}, function(err, rooms){// find the chat content of the room
      		if (err) {
            console.log(error);
      			return res.status(400).send("err in get /getChattingMessageInRoom");
      		} else {
            return res.send(rooms[0].chatContent)
          }
        });
      }
    }
  });

});

router.get('/keyWord', function(req, res, next) {
  res.send(questionBank[0].keyWord);
});

router.get('/hint', function(req, res, next) {
  res.send(questionBank[0].hint);
});

/*
router.post('/createRoom', function(req, res, next) {
  var userID = req.body.
  console.log(task);
  //res.json({message: 'Task is ' + task});
  Task.create({task: task, create_at : date}, function(err, task){
		if (err) {
			return res.status(400).send("err in post /task");
		} else {
			return res.status(200).json(task);
		}
	});
});
*/
module.exports = router;

var questionBank = [
  {
    keyWord: "铅笔",
    hint: "一种文具"
  },
];

var gameRooms = [
  {
    roomId: 1001
  },
];
