var express = require('express');
var router = express.Router();
var Question = require('../models/Question');
var GameRoom = require('../models/GameRoom');
var PlayerList = require('../models/Player');

router.get('/', function(req, res, next) {
  res.send("This is a response to get.");
});

router.get('/playerRole', function(req, res, next) {
  var roomID = Number(req.query.roomId);
  var playerID = Number(req.query.playerId);
  var questionNumber;
  GameRoom.find({roomId: roomID}, function(err, tasks) {
    if (tasks[0].players[tasks[0].drawerNumber].id == playerID) {
      res.send("Drawer");
    } else {
      res.send("Guesser");
    }
  });
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

router.delete('/deleteAllPlayers', function(req, res, next) {
  PlayerList.remove({}, function(err, tasks){
		if(err){
			return res.status(400).send("err in get /getAllPlayers");
		}else{
			console.log(tasks);
			return res.status(200).json("delete all players");
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

  var randomQuestionId = 1 + Math.round(Math.random()*(questionBank.length-2)); // 1 ~ (questionBank.length-1)

  GameRoom.create({roomId: randomId, questionNumber: randomQuestionId}, function(err){
		if (err) {
      console.log(err);
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
        console.log(err);
        return res.status(400).send("err in delete /task");
    } else {
        return res.status(200).json([{roomId: roomID}]);
        console.log('delete ok!');
    }
  });

});

router.delete('/deleteAllRooms', function(req, res, next) {

  GameRoom.remove({}, function(error) {
    if(error) {
        console.log(err);
        return res.status(400).send("err in delete /task");
    } else {
        return res.status(200).json("delete all rooms.");
        console.log('delete ok!');
    }
  });

});

router.post('/getPlayerIDsInRoom', function(req, res, next) {
  var roomID = req.query.roomId;

  GameRoom.find({roomId: roomID}, function(err, tasks){
		if (err) {
      console.log(err);
			return res.status(400).send("err in get /getPlayersInRoom");
		} else {
      if (tasks.length < 1) {
        return res.status(400).send("No room found with id " + roomID);
      } else {
        console.log("getPlayersInRoom room.");
        console.log(tasks[0].players);
        return res.status(200).json(tasks[0].players);
      }
		}
	});
});

router.post('/getPlayerInfoWithId', function(req, res, next) {
  var playerID = req.query.playerId;

  PlayerList.find({Id: playerID}, function(err, tasks){
		if (err) {
      console.log(err);
			return res.status(400).send("err in get /getPlayerInfoWithId");
		} else {
      if (tasks.length < 1) {
        return res.status(400).send("No player found with id " + playerID);
      } else {
        console.log("getPlayerInfoWithId.");
        return res.status(200).json(tasks);
      }
		}
	});
});

router.put('/addPlayerToRoom', function(req, res, next) {
  var roomID = req.query.roomId;
  var playerId = Number(req.query.playerId);
  //console.log(playerId);

  GameRoom.update({roomId: roomID}, {$push : {players: {id: playerId}}}, function(err, tasks){
		if (err) {
      console.log(err);
			return res.status(400).send("err in post /addPlayerToRoom");
		} else {
      console.log("add player with id " + playerId + " to room with roomId " + roomID);
      PlayerList.update({Id: playerId}, {roomNumber: roomID}, function(err, tasks2) {
        console.log(tasks2);
      });
			return res.status(200).json([tasks]);
		}
	});

});

router.put('/removePlayerFromRoom', function(req, res, next) {
  var roomID = req.query.roomId;
  var playerId = Number(req.query.playerId);

  GameRoom.update({roomId: roomID}, {$pull : {players: {id: playerId}}}, function(err, tasks){
		if (err) {
      console.log(err);
			return res.status(400).send("err in post /removePlayerFromRoom");
		} else {
      console.log("remove player with id " + playerId + " to room with roomId " + roomID);
      GameRoom.find({roomId: roomID}, function(err, tasks2){
        if (tasks2[0].players.length < 1) {
          GameRoom.remove({roomId: roomID}, function(err, tasks3){
            console.log("room is empty. remove room.");
          });
        }
      });
			return res.status(200).json([tasks]);
		}
	});

});

router.post('/sendChattingMessageInRoom', function(req, res, next) {
  var roomID = req.query.roomId;
  var playerName = req.query.playerName;
  var message = req.query.content;
  var fullMessage = String(playerName) + ": " + String(message);

  GameRoom.update({roomId: roomID}, {chatContent: fullMessage}, function(err, tasks){
		if (err) {
      console.log(err);
			return res.status(400).send("err in post /sendChattingMessage");
		} else {
      console.log("sendChattingMessage to room " + roomID);
      console.log(message);

      PlayerList.find({roomNumber: roomID}, function(err, players) {
        players.forEach(function(item) {
            PlayerList.update({isNotified: 1}, {isNotified: 0}, function(err, tasks2) {
              console.log(tasks2);
            });
        });
      });
			return res.status(200).json([tasks]);
    }
	});
});

router.post('/getChattingMessageInRoom', function(req, res, next) {
  var roomID = req.query.roomId;
  var playerId = Number(req.query.playerId);

  PlayerList.find({Id: playerId}, function(err, players){//find user check isNotified state
    if (err) {
      console.log(err);
      return res.send("");
    } else {
      console.log(players);
      if (players.length < 1 || players[0].isNotified == 1) {
        console.log("is notified");
        return res.send("");
      } else {
        GameRoom.find({roomId: roomID}, function(err, rooms){// find the chat content of the room
      		if (err) {
            console.log(error);
      			return res.status(400).send("err in get /getChattingMessageInRoom");
      		} else {
            console.log("is not notified");
            PlayerList.update({Id: playerId}, {isNotified: 1}, function(err, tasks) {
              console.log(tasks);
            });
            return res.send([String(rooms[0].chatContent)]);
          }
        });
      }
    }
  });

});


/*
route.post('/playerGetReady', function(req, res, next) {
  var playerID = req.query.playerId;
  var roomID = req.query.roomId;

  PlayerList.update({Id: playerID}, {isReady: 1}, function(err, tasks) {
    if(err) {
      console.log(err);
      return res.status(400).send("err in post /playerGetReady");
    } else {
      console.log(tasks);
      GameRoom.update({roomId: roomID}, {$inc:{readyNumber: 1}}, function(err, tasks2) {
        console.log(tasks2);
        if()
      });
      return res.status(200).send([tasks]);
    }
  });
});

route.post('/playerResetReady', function(req, res, next) {
  var playerID = req.query.playerId;
  PlayerList.update({Id: playerID}, {isReady: 0}, function(err, tasks) {
    if(err) {
      console.log(err);
      return res.status(400).send("err in post /playerResetReady");
    } else {
      console.log(tasks);
      return res.status(200).send([tasks]);
    }
  });
});
*/
router.post('/beginGameInRoom', function(req, res, next) {
  var roomID = req.query.roomId;
  GameRoom.update({roomId: roomID}, {gameState: 2}, function(err, tasks) {
    if(err) {
      console.log(err);
      return res.status(400).send("err in post /getGameStateInRoom");
    } else {
      console.log(tasks);
      return res.status(200).send([tasks]);
    }
  });
});

router.post('/getGameStateInRoom', function(req, res, next) {
  var roomID = req.query.roomId;
  GameRoom.find({roomId: roomID}, function(err, tasks) {
    if(err) {
      console.log(err);
      return res.status(400).send("err in post /getGameStateInRoom");
    } else {
      console.log(tasks);
      return res.status(200).send([Number(tasks[0].gameState)]);
    }
  });
});

router.get('/keyWord', function(req, res, next) {
  res.send(questionBank[0].keyWord);
});
router.get('/getKeyWordInRoom', function(req, res, next) {
  var roomID = Number(req.query.roomId);
  var questionNumber;
  GameRoom.find({roomId: roomID}, function(err, tasks) {
    questionNumber = Number(tasks[0].questionNumber);
    res.send(questionBank[questionNumber].keyWord);
  });
});

router.get('/hint', function(req, res, next) {
  res.send(questionBank[0].hint);
});
router.get('/getHintInRoom', function(req, res, next) {
  var roomID = Number(req.query.roomId);
  var questionNumber;
  GameRoom.find({roomId: roomID}, function(err, tasks) {
    //console.log(tasks);
    questionNumber = Number(tasks[0].questionNumber);
    //console.log(Number(questionNumber));
    res.send(questionBank[Number(questionNumber)].hint);
  });

  /*
  console.log(questionBank[3]);
  console.log(Number(questionNumber));
  console.log(questionBank[Number(questionNumber)]);
  */

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

router.post('/sendDrawingBoard', function(req, res, next) {
  var roomID = Number(req.query.roomId);
  var image = Object(req.body.image);
  var brushState = String(req.body.brushState);
  var brushPositionX = Number(req.body.brushPositionX);
  var brushPositionY = Number(req.body.brushPositionY);
  var brushKind = (String)(req.body.brushKind);
  var brushColor = (String)(req.body.brushColor);

/*
  console.log(image);
  console.log(brushState);
  console.log(brushPositionX);
  console.log(brushPositionY);
  console.log(brushKind);
  console.log(brushColor);
*/
  //drawingBoardImage = new Buffer(JSON.parse(image));
  //return res.status(200).send(["sendDrawingBoard"]);

  GameRoom.update({roomId: roomID},
    {
      brushState: brushState,
      brushPositionX: brushPositionX,
      brushPositionY: brushPositionY,
      brushKind: brushKind,
      brushColor: brushColor
    },
    function(err, tasks) {
      if(err) {
        console.log(err);
        return res.status(400).send("err in post /getGameStateInRoom");
      } else {
        console.log(tasks);
        return res.status(200).send([tasks]);
      }
  });

});

router.get('/getDrawingBoard', function(req, res, next) {
  var roomID = Number(req.query.roomId);
  //return res.send(drawingBoardImage);

  GameRoom.find({roomId: roomID}, function(err, tasks) {
    if(err) {
      console.log(err);
      return res.status(400).send("err in post /getGameStateInRoom");
    } else {
      return res.status(200).json(tasks[0]);
    }
  });

});

router.post('/')
module.exports = router;

var drawingBoardImage;
var questionBank = [
  {
    // this is not a real question, normally this question should not be sent to clients.
    // just to check if it is working properly.
    keyWord: "测试",
    hint: "测试"
  },
  {
    keyWord: "铅笔",
    hint: "一种文具"
  },
  {
    keyWord: "三长两短",
    hint: "四字成语"
  },
  {
    keyWord: "日本",
    hint: "一个国家"
  },
  {
    keyWord: "钻石",
    hint: "奢侈品"
  },
  {
    keyWord: "XBox",
    hint: "娱乐用品"
  },
];
