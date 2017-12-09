var mongoose = require('mongoose');

var GameRoomSchema = new mongoose.Schema({
  roomId: Number,
  chatContent: {
    type: String,
    default: "Hello Everyone!"
  },
  players: {
    type: Array,
    /*
    player Ids
    */
  },
  questionNumber: {
    type: Number,
    default: 0
  },
  drawerNumber: {
    type: Number,
    default: 0
  },
  readyNumber: {
    type: Number,
    default: 0
  },
  gameState:{
    type: Number,
    default: 0
    /*
    0: ended
    1: readyToBegin
    2: onGoing
    */
  }
});

module.exports = mongoose.model("GameRoom", GameRoomSchema);
