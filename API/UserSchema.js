var mongoose     = require('mongoose');
var Schema       = mongoose.Schema;

var UserSchema = new Schema({
	_id: String,
	username: String,
	password: String,
	email: String,
	friends: [String],
	messages: [{
		_id: String,
		createdBy: String,
		dateCreated: String,
		text: String,
		responseNum: Number,
		answers: [{
			sentBy: String,
			dateCreated: String,
			text: String,
			likeNum: Number
		}]
	}]
});

module.exports = mongoose.model('User', UserSchema);