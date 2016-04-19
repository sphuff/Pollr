var MongoClient = require('mongodb').MongoClient;
var express        =        require("express");
var app            =        express();

// app.listen(4000, function () {
//   console.log('App listening on port 4000!');
// });

MongoClient.connect('mongodb://127.0.0.1:27017/Pollr', function(err, db) {
  if (err) {
    throw err;
  } 
  var collection = db.collection('users');
  // Locate all the entries using find
	collection.removeMany();
	db.close();
});	