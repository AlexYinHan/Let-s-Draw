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
  },
  //drawingBoard: Object,
  brushState: {
    type: String,
    default: "Ended"
  },
  brushPositionX: {
    type: Number,
    default: 0
  },
  brushPositionY: {
    type: Number,
    default: 0
  },
  brushKind: {
    type: String,
    default: "Eraser"
  },
  brushColor: {
    type: String,
    default: "Red"
  },
});

module.exports = mongoose.model("GameRoom", GameRoomSchema);
