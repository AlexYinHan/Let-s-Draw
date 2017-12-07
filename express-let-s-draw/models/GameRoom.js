var mongoose = require('mongoose');

var GameRoomSchema = new mongoose.Schema({
  roomId: Number,
  players: {
    type: Array,
    default: [
      {
        name: "Jackson",
        photo: 0
      },
      {
        name: "Lina",
        photo: 0
      },
    ]
  }
});

module.exports = mongoose.model("GameRoom", GameRoomSchema);
