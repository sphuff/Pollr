var express        =        require("express");
var bodyParser     =        require("body-parser");
var app            =        express();
var ObjectID = require('mongodb').ObjectID;
//Here we are configuring express to use body-parser as middle-ware.
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

var MongoClient = require('mongodb').MongoClient
	, format = require('util').format;

app.listen(3000, function () {
  console.log('App listening on port 3000!');
});

app.get('/', function (req, res) {
  res.send('Hello World!');
});

app.get('/users/:username', function(req, res){
  MongoClient.connect('mongodb://127.0.0.1:27017/Pollr', function(err, db) {
  if (err) {
    throw err;
  } 
  var collection = db.collection('users');
  // Locate all the entries using find
    collection.find({"username": req.params.username}).toArray(function(err, results) {
      res.setHeader('Content-Type', 'application/json');
      res.send(JSON.stringify(results));
      // Let's close the db
      db.close();
    });
  });
});

app.get('/allUsers/:username', function(req, res){
  MongoClient.connect('mongodb://127.0.0.1:27017/Pollr', function(err, db) {
  if (err) {
    throw err;
  } 
  var collection = db.collection('users');
  // Locate all the entries using find
    collection.find({ "username": { "$regex": req.params.username, "$options": "i" } }).toArray(function(err, results) {
      if(results.length > 15){
          results = results.slice(0,15);
      }

      var usernameArray = [];
      for(i = 0; i < results.length; i++){
          usernameArray.push(results[i].username);
      }

      res.setHeader('Content-Type', 'application/json');
      res.send(JSON.stringify(usernameArray));
      // Let's close the db
      db.close();
    });
  });
});

app.post('/addUser', function(req, res){
    MongoClient.connect('mongodb://127.0.0.1:27017/Pollr', function(err, db){
      console.dir("Connected");
      if(err) {
        throw err;
      }
      var collection = db.collection('users');
      collection.insert({"username" : req.body.username, "password" : req.body.password, "email" : req.body.email, "friends" : [], "messages" : []}, function (err, results){
        res.setHeader('Content-Type', 'application/json');
        res.send(JSON.stringify(results));
        db.close();
      });
    });
});

app.post('/addFriendFor:user', function(req, res){
    MongoClient.connect('mongodb://127.0.0.1:27017/Pollr', function(err, db){
      console.dir("Connected");
      if(err) {
        throw err;
      }
      var collection = db.collection('users');
      collection.update(
        { "username" : req.params.user},
        { $push: {friends: req.body[0]}} , function (err, results){
        res.setHeader('Content-Type', 'application/json');
        res.send(JSON.stringify(results));
        db.close();
      });
    });
});


app.delete('/removeFriendFor:user', function(req, res){
    MongoClient.connect('mongodb://127.0.0.1:27017/Pollr', function(err, db){
      console.dir("Connected");
      if(err) {
        throw err;
      }
      var collection = db.collection('users');
      collection.update(
        { "username" : req.params.user},
        { $pull: {friends: req.body[0]}} , function (err, results){
        res.setHeader('Content-Type', 'application/json');
        res.send(JSON.stringify(results));
        db.close();
      });
    });
});

app.delete('/removeFriendsFor:user', function(req, res){
    MongoClient.connect('mongodb://127.0.0.1:27017/Pollr', function(err, db){
      console.dir("Connected");
      if(err) {
        throw err;
      }
      var collection = db.collection('users');
      collection.update(
        { "username" : req.params.user},
        { $set: {"friends": []}} , function (err, results){
        res.setHeader('Content-Type', 'application/json');
        res.send(JSON.stringify(results));
        db.close();
      });
    });
});

app.get('/friendsFor:username', function(req, res){
  MongoClient.connect('mongodb://127.0.0.1:27017/Pollr', function(err, db) {
  if (err) {
    throw err;
  } 
  var collection = db.collection('users');
  // Locate all the entries using find
    collection.find({"username": req.params.username}).toArray(function(err, results) {

      res.setHeader('Content-Type', 'application/json');
      res.send(JSON.stringify(results[0].friends));
      // Let's close the db
      db.close();
    });
  });
});

app.post('/sendPrivateMessage', function(req, res){
      MongoClient.connect('mongodb://127.0.0.1:27017/Pollr', function(err, db){
      console.dir("Connected");
      if(err) {
        throw err;
      }
      var collection = db.collection('users');
      var sendTo = req.body.sentTo; 
      var messageID = ObjectID();
      for(i = 0; i < sendTo.length; i++){
          collection.update(
            { "username" : sendTo[i]},
            { $push: {messages: {"id" : messageID, "createdBy" : req.body.createdBy,
              "dateCreated" : req.body.dateCreated, "text" : req.body.text,
              "responseNum" : 0}}}
          );
          if(i == sendTo.length - 1){
              res.setHeader('Content-Type', 'application/json');
              res.send(JSON.stringify(messageID));
              db.close();
          }
      }
  });
});

app.delete('/removePrivateMessagesFor:user', function(req, res){
    MongoClient.connect('mongodb://127.0.0.1:27017/Pollr', function(err, db){
      console.dir("Connected");
      if(err) {
        throw err;
      }
      var collection = db.collection('users');
      collection.update(
        { "username" : req.params.user},
        { $set: {"messages": []}} , function (err, results){
        res.setHeader('Content-Type', 'application/json');
        res.send(JSON.stringify(results));
        db.close();
      });
    });
});

app.post('/sendPublicMessage', function(req, res){
    MongoClient.connect('mongodb://127.0.0.1:27017/Pollr', function(err, db){
      console.dir("Connected");
      if(err) {
        throw err;
      }
      var collection = db.collection('publicMessages');
      collection.insert({"createdBy" : req.body.createdBy, "dateCreated" : req.body.dateCreated, "text" : req.body.text}, function (err, results){
        res.setHeader('Content-Type', 'application/json');
        res.send(JSON.stringify(results));
        db.close();
      });
    });
});

app.get('/getPublicMessages', function(req, res){
    MongoClient.connect('mongodb://127.0.0.1:27017/Pollr', function(err, db){
      console.dir("Connected");
      if(err) {
        throw err;
      }
      var collection = db.collection('publicMessages');
      collection.find().sort({"dateCreated": -1}).toArray(function (err, results){
        res.setHeader('Content-Type', 'application/json');
        res.send(JSON.stringify(results));
        db.close();
      });
    });
});

app.get('/getPrivateMessagesFor:user', function(req, res){
    MongoClient.connect('mongodb://127.0.0.1:27017/Pollr', function(err, db){
      console.dir("Connected");
      if(err) {
        throw err;
      }
      var collection = db.collection('users');
      collection.aggregate([ 
        {$unwind : "$messages"}, 
        {$match : {"username" : req.params.user}}, 
        {$project : {_id : 0, id : "$messages.id", 
        "createdBy" : "$messages.createdBy", "dateCreated": "$messages.dateCreated",
         "title": "$messages.title", "answers": "$messages.answers"}}
         ], function(err, results){
              res.setHeader('Content-Type', 'application/json');
              res.send(JSON.stringify(results));
              db.close();
         });
    });
});
