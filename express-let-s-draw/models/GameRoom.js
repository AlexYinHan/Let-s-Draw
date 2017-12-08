var mongoose = require('mongoose');

var GameRoomSchema = new mongoose.Schema({
  roomId: Number,
  players: {
    type: Array,
    default: [
      {
        photo: 0,
        name: "Jackson",      
      },
      {
        photo: 0,
        name: "Lina",
      },
    ]
  }
});

module.exports = mongoose.model("GameRoom", GameRoomSchema);
