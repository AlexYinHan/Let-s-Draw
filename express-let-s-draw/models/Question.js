var mongoose = require('mongoose');

var QuestionSchema = new mongoose.Schema({
  keyWord: String,
  hint: String
});

module.exports = mongoose.model("Question", QuestionSchema);
