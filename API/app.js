/*jslint node: true */
/*jslint white: true */
/*jslint plusplus: true */
/*jshint -W024 */
/*jshint -W105 */
/*jshint es5: true */

"use strict";
var express        =        require("express");
var mongoose       =        require('mongoose');
var bodyParser     =        require("body-parser");
var app            =        express();
var router         =        express.Router();
var ObjectID = require('mongodb').ObjectID;
var config         =        require('./config');
var jwt            =        require('jsonwebtoken');
//Here we are configuring express to use body-parser as middle-ware.
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());
app.set('jwtKey', config.key);

var MongoClient = require('mongodb').MongoClient,
	format = require('util').format;


app.use('/api', router);

app.listen(3000, function () {
  console.log('App listening on port 3000!');
});

router.get('/', function (req, res) {
  res.send('Hello World!');
});

router.post('/authenticate', function (req, res){
    MongoClient.connect(config.database, function(err, db) {
    if (err) {
      throw err;
    } 
    res.setHeader('Content-Type', 'application/json');
    var collection = db.collection('users'),
    token;
    collection.find({"username": req.body.username}).toArray(function(err, results){
        var user = results[0];
        if(results.length < 1){
            res.status(404).json({"success" : "false", "message" : "User not found"}); // Not Found
        } else if(user.password !== req.body.password){
            res.status(401).json({"success" : "false", "message" : "Improper credentials"}); // Unauthorized
        } else {
            token = jwt.sign(user, app.get('jwtKey'), {
                expiresIn: "1d" // expires in 24 hours
            });
            res.json({"success" : "true", "token" : token});
        }
        db.close();
    });
  });
});

router.use(function(req, res, next){
    var token = req.body.token || req.headers.token;
    if(token){
      jwt.verify(token, app.get('jwtKey'), function(err, decoded){
          if(err){
              return res.json({"success" : "false", "message" : "Failed to authenticate token"});
          } else {
              next();
          }
      });
    } else { // no token found
        res.setHeader('Content-Type', 'application/json');
        return res.status(403).json({"success" : "false", "message" : "No token provided"});
    }
});

router.get('/users/:username', function(req, res){
  MongoClient.connect(config.database, function(err, db) {
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

router.post('/userExists', function(req, res){
  MongoClient.connect(config.database, function(err, db) {
  if (err) {
    throw err;
  } 
  var collection = db.collection('users');
  // Locate all the entries using find
    collection.find({"username": req.body.username}).toArray(function(err, results) {
      res.setHeader('Content-Type', 'application/json');
      var user = results[0];
      if(results.length < 1){
          res.sendStatus(404); // Not Found
      } else if(user.password !== req.body.password){
          res.sendStatus(401); // Unauthorized
      } else {
          res.sendStatus(200);
      }
      // Let's close the db
      db.close();
    });
  });
});

router.get('/allUsers/:username', function(req, res){
  MongoClient.connect(config.database, function(err, db) {
  if (err) {
    throw err;
  } 
  var collection = db.collection('users'),
      i;
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

router.post('/addUser', function(req, res){
    MongoClient.connect(config.database, function(err, db){
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

router.post('/addFriendFor:user', function(req, res){
    MongoClient.connect(config.database, function(err, db){
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


router.delete('/removeFriendFor:user', function(req, res){
    MongoClient.connect(config.database, function(err, db){
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

router.delete('/removeFriendsFor:user', function(req, res){
    MongoClient.connect(config.database, function(err, db){
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

router.get('/friendsFor:username', function(req, res){
  MongoClient.connect(config.database, function(err, db) {
  if (err) {
    throw err;
  } 
  var collection = db.collection('users');
  // Locate all the entries using find
    collection.find({"username": req.params.username}).toArray(function(err, results) {

      res.setHeader('Content-Type', 'application/json');
      if(results.length == 0){
        res.send([]);
      } else {
        res.send(JSON.stringify(results[0].friends));
      }
      // Let's close the db
      db.close();
    });
  });
});

router.post('/sendPrivateMessage', function(req, res){
      MongoClient.connect(config.database, function(err, db){
      console.dir("Connected");
      if(err) {
        throw err;
      }
      var collection = db.collection('users'),
          viewers = req.body.viewers, // includes sender
          i,
          messageID = new ObjectID(),
          ret;
      var bulk = collection.initializeUnorderedBulkOp();

      for(i = 0; i < sendTo.length; i++){
          bulk.find(
            { "username" : viewers[i]}).update(
              { $push: {messages: {"id" : messageID, "createdBy" : req.body.createdBy,
                "dateCreated" : req.body.dateCreated, "text" : req.body.text,
                "responseNum" : 0, "viewers": viewers}}}
          );
          if(i === viewers.length - 1){
              res.setHeader('Content-Type', 'application/json');
              ret = [messageID];
              res.send(JSON.stringify(ret));
          }
      }
      bulk.execute();
      db.close();
  });
});

router.delete('/removePrivateMessagesFor:user', function(req, res){
    MongoClient.connect(config.database, function(err, db){
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

router.post('/sendPublicMessage', function(req, res){
    MongoClient.connect(config.database, function(err, db){
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

router.get('/getPublicMessages', function(req, res){
    MongoClient.connect(config.database, function(err, db){
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

router.get('/getPrivateMessagesFor:user', function(req, res){
    MongoClient.connect(config.database, function(err, db){
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
         "text": "$messages.text", "responseNum": "$messages.responseNum"}}
         ], function(err, results){
              res.setHeader('Content-Type', 'application/json');
              res.send(JSON.stringify(results));
              db.close();
         });
    });
});
