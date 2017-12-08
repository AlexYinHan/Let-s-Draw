var mongoose = require('mongoose');

var PlayerSchema = new mongoose.Schema({
  isNotified: {
    type:  Number,
    default: 0
  },
  roomNumber: {
    type: Number,
    default: -1
  },
  name: String,
  Id: Number,

});

module.exports = mongoose.model("Player", PlayerSchema);
