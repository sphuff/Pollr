var MongoClient = require('mongodb').MongoClient;
var faker = require('faker');
var jsSHA = require('jssha');

MongoClient.connect('mongodb://127.0.0.1:27017/Pollr', function(err, db) {
  var i;
  var j;
  var collection = db.collection('users');
  var bulk = collection.initializeUnorderedBulkOp();

  // generate users
  for(i = 0; i < 10; i+=1){
	  var username = faker.internet.userName();
	  var password = faker.internet.password();
	  var email = faker.internet.email();

	  var shaObj = new jsSHA("SHA-512", "TEXT");
	  shaObj.update(password);
	  var hash = shaObj.getHash("HEX");

	  bulk.insert({"userNum": i, "username" : username, "password" : hash, "email" : email, "friends" : [], "messages" : []});
	  console.log("Added user #" + i);
  }
  bulk.execute();
  // add friends
  var i;
	var j;
	var random = Math.random(Date());
	var collection = db.collection('users');
	for(i = 0; i < 10; i+=1){
		index = Math.floor((random * 10) + 1); // number of friends

		for(j = 0; j < index; j+=1){
			friendNum = Math.floor(random * 10);
			collection.find({"userNum": j}).toArray(function(err, results){
				console.log("Friend is " + results[0] );
				db.close();
			});
		}
	}
});	

var addFriends = function(db, callback) {
   
};