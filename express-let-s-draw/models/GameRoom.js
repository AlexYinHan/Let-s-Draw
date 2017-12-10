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
  drawingBoard: Object,
  brushState: {
    type: Number,
    default: 0
    /*
    0: ended
    1: begined
    2: moved
    */
  },
  brushPositionX: Number,
  brushPositionY: Number,
  brushKind: {
    type: Number,
    default: 0
    /*
    0: eraser
    1: pencil
    */
  },
  brushColor: {
    type: Number,
    default: 0
    /*
    0: red
    1: white
    */
  },
});

module.exports = mongoose.model("GameRoom", GameRoomSchema);
