var express = require('express');
var router = express.Router();
var Question = require('../models/Question')

router.get('/', function(req, res, next) {
  res.send("This is a response to get.");
});

router.get('/playerRole', function(req, res, next) {
  res.send("Guesser");
});


router.get('/createRoom', function(req, res, next) {
  res.send("1");
});

router.get('/keyWord', function(req, res, next) {
  res.send(questionBank[0].keyWord);
});

module.exports = router;

var questionBank = [
  {
    keyWord: "铅笔",
    hint: "一种文具"
  },
];
