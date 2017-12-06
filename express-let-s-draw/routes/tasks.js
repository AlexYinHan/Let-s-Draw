var express = require('express');
var router = express.Router();

router.get('/', function(req, res, next) {
  res.send("This is a response to get.");
});

router.get('/playerRole', function(req, res, next) {
  res.send("Guesser");
});

module.exports = router;
