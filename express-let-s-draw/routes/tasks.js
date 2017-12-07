var express = require('express');
var router = express.Router();
var Question = require('../models/Question');
var GameRoom = require('../models/GameRoom');

router.get('/', function(req, res, next) {
  res.send("This is a response to get.");
});

router.get('/playerRole', function(req, res, next) {
  res.send("Drawer");
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

router.post('/createRoom', function(req, res, next) {
  var roomID = 1001;

  GameRoom.create({roomId: roomID}, function(err){
		if (err) {
      console.log(error);
			return res.status(400).send("err in createRoom /get");
		} else {
      console.log("create room.");
      console.log({roomId: roomID});
			return res.status(200).json([{roomId: roomID}]);
		}
	});

});

router.delete('/deleteRoom', function(req, res, next) {
  var roomID = req.body.roomId;


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
      console.log("getPlayersInRoom room.");
      console.log(tasks[0].players);
      console.log(tasks);
			return res.status(200).json(tasks[0].players);
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
