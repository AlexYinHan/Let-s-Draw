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
    default: [
      {
        //isNotified: 1,
        //photo: 0,
        id: 1
      },
      {
        //isNotified: 1,
        //photo: 0,
        name: "Lina",
      },
    ]*/
  }
});

module.exports = mongoose.model("GameRoom", GameRoomSchema);
