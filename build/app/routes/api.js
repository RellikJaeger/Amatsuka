(function() {
  var ConfigProvider, PictCollection, PictProvider, TwitterClient, UserProvider, chalk, moment, my, path, settings, twitterUtils, _;

  moment = require('moment');

  _ = require('lodash');

  path = require('path');

  chalk = require('chalk');

  TwitterClient = require(path.resolve('build', 'lib', 'TwitterClient'));

  PictCollection = require(path.resolve('build', 'lib', 'PictCollection'));

  my = require(path.resolve('build', 'lib', 'my')).my;

  twitterUtils = require(path.resolve('build', 'lib', 'twitterUtils')).twitterUtils;

  UserProvider = require(path.resolve('build', 'lib', 'model')).UserProvider;

  ConfigProvider = require(path.resolve('build', 'lib', 'model')).ConfigProvider;

  PictProvider = require(path.resolve('build', 'lib', 'model')).PictProvider;

  settings = process.env.NODE_ENV === 'production' ? require(path.resolve('build', 'lib', 'configs', 'production')) : require(path.resolve('build', 'lib', 'configs', 'development'));

  module.exports = function(app) {

    /*
    Middleware
     */
    var fetchTweet;
    app.use('/api/?', function(req, res, next) {
      console.log("======> " + req.originalUrl);
      if (!_.isUndefined(req.session.passport.user)) {
        return next();
      } else {
        return res.redirect('/');
      }
    });

    /*
    APIs
     */
    app.post('/api/download', function(req, res) {
      console.log("\n========> download, " + req.body.url + "\n");
      return my.loadBase64Data(req.body.url).then(function(base64Data) {
        console.log('base64toBlob', base64Data.length);
        return res.json({
          base64Data: base64Data
        });
      });
    });
    app.get('/api/collect/count', function(req, res) {
      return PictProvider.count().then(function(count) {
        return res.json({
          count: count
        });
      })["catch"](function(err) {
        return console.log(err);
      });
    });
    app.get('/api/collect/:skip?/:limit?', function(req, res) {
      return PictProvider.find({
        skip: req.params.skip - 0,
        limit: req.params.limit - 0
      }).then(function(data) {
        return res.send(data);
      });
    });
    app.post('/api/collect/profile', function(req, res) {
      var pictCollection;
      pictCollection = new PictCollection(req.session.passport.user, req.body.twitterIdStr);
      return pictCollection.getIllustratorTwitterProfile().then(function(data) {
        return pictCollection.setIllustratorRawData(data);
      }).then(function() {
        return pictCollection.getIllustratorRawData();
      }).then(function(illustratorRawData) {
        return pictCollection.setUserTimelineMaxId(illustratorRawData.status.id_str);
      }).then(function() {
        return pictCollection.normalizeIllustratorData();
      }).then(function() {
        return pictCollection.updateIllustratorData();
      }).then(function(data) {
        return pictCollection.setIllustratorDBData(data);
      }).then(function(data) {
        console.log('End PictProvider.findOneAndUpdate data = ', data);
        return res.send(data);
      })["catch"](function(err) {
        return console.log(err);
      });
    });

    /*
    Twitter
     */
    app.post('/api/findUserById', function(req, res) {
      console.log("\n============> findUserById in API\n");
      return UserProvider.findUserById({
        twitterIdStr: req.session.passport.user._json.id_str
      }, function(err, data) {
        return res.json({
          data: data
        });
      });
    });
    app.get('/api/lists/list/:id?/:count?', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterClient(req.session.passport.user);
      return twitterClient.getListsList({
        twitterIdStr: req.params.id,
        count: req.params.count
      }).then(function(data) {
        console.log('/api/lists/list/:id/:count data.length = ', data.length);
        return res.json({
          data: data
        });
      })["catch"](function(error) {
        console.log('/api/lists/list/:id/:count error = ', error);
        return res.json({
          error: error
        });
      });
    });
    app.post('/api/lists/create', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterClient(req.session.passport.user);
      return twitterClient.createLists({
        name: req.body.name,
        mode: req.body.mode
      }).then(function(data) {
        console.log('/api/lists/create', data.length);
        return res.json({
          data: data
        });
      })["catch"](function(error) {
        return res.json({
          error: error
        });
      });
    });
    app.get('/api/lists/members/:id?/:count?', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterClient(req.session.passport.user);
      return twitterClient.getListsMembers({
        listIdStr: req.params.id,
        count: req.params.count
      }).then(function(data) {
        console.log('/api/lists/members/:id/:count data.length = ', data.length);
        return res.json({
          data: data
        });
      })["catch"](function(error) {
        return res.json({
          error: error
        });
      });
    });
    fetchTweet = function(req, res, queryType, maxId, config) {
      var params, twitterClient;
      maxId = maxId || req.params.maxId;
      params = {};
      switch (queryType) {
        case 'getListsStatuses':
          params = {
            listIdStr: req.params.id,
            maxId: maxId,
            count: req.params.count,
            includeRetweet: config.includeRetweet
          };
          break;
        case 'getHomeTimeline':
        case 'getUserTimeline':
          params = {
            twitterIdStr: req.params.id,
            maxId: maxId,
            count: req.params.count,
            includeRetweet: req.query.isIncludeRetweet || config.includeRetweet
          };
          break;
        default:
          res.json({
            data: null
          });
      }
      twitterClient = new TwitterClient(req.session.passport.user);
      return twitterClient[queryType](params).then(function(tweets) {
        var tweetsNormalized;
        maxId = my.decStrNum(_.last(tweets).id_str);
        tweetsNormalized = twitterUtils.normalizeTweets(tweets, config);
        if (!_.isEmpty(tweetsNormalized)) {
          res.json({
            data: tweetsNormalized
          });
        }
        return fetchTweet(req, res, queryType, maxId, config);
      })["catch"](function(error) {
        return res.json({
          error: error
        });
      });
    };
    app.get('/api/lists/statuses/:id/:maxId?/:count?', function(req, res) {
      return ConfigProvider.findOneById({
        twitterIdStr: req.session.passport.user._json.id_str
      }, function(err, data) {
        var config;
        config = _.isNull(data) ? {} : JSON.parse(data.configStr);
        return fetchTweet(req, res, 'getListsStatuses', null, config);
      });
    });
    app.get('/api/timeline/:id/:maxId?/:count?', function(req, res) {
      return ConfigProvider.findOneById({
        twitterIdStr: req.session.passport.user._json.id_str
      }, function(err, data) {
        var config, queryType;
        config = _.isNull(data) ? {} : JSON.parse(data.configStr);
        queryType = req.params.id === 'home' ? 'getHomeTimeline' : 'getUserTimeline';
        return fetchTweet(req, res, queryType, null, config);
      });
    });
    app.get('/api/statuses/show/:id', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterClient(req.session.passport.user);
      return twitterClient.showStatuses({
        tweetIdStr: req.params.id
      }).then(function(data) {
        return res.json({
          data: data
        });
      })["catch"](function(error) {
        return res.json({
          error: error
        });
      });
    });
    app.get('/api/users/show/:id/:screenName?', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterClient(req.session.passport.user);
      return twitterClient.showUsers({
        twitterIdStr: req.params.id,
        screenName: req.params.screenName
      }).then(function(data) {
        return res.json({
          data: data
        });
      })["catch"](function(error) {
        return res.json({
          error: error
        });
      });
    });
    app.get('/api/friends/list/:id?/:cursor?/:count?', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterClient(req.session.passport.user);
      return twitterClient.getFollowingList({
        twitterIdStr: req.params.id,
        cursor: req.params.cursor - 0,
        count: req.params.count - 0
      }).then(function(data) {
        return res.json({
          data: data
        });
      })["catch"](function(error) {
        return res.json({
          error: error
        });
      });
    });
    app.post('/api/lists/members/create', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterClient(req.session.passport.user);
      return twitterClient.createListsMembers({
        listIdStr: req.body.listIdStr,
        twitterIdStr: req.body.twitterIdStr
      }).then(function(data) {
        return res.json({
          data: data
        });
      })["catch"](function(error) {
        return res.json({
          error: error
        });
      });
    });
    app.post('/api/lists/members/create_all', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterClient(req.session.passport.user);
      return twitterClient.createAllListsMembers({
        listIdStr: req.body.listIdStr,
        twitterIdStr: req.body.twitterIdStr
      }).then(function(data) {
        return res.json({
          data: data
        });
      })["catch"](function(error) {
        return res.json({
          error: error
        });
      });
    });
    app.post('/api/lists/members/destroy', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterClient(req.session.passport.user);
      return twitterClient.destroyListsMembers({
        listIdStr: req.body.listIdStr,
        twitterIdStr: req.body.twitterIdStr
      }).then(function(data) {
        return res.json({
          data: data
        });
      })["catch"](function(error) {
        return res.json({
          error: error
        });
      });
    });

    /*
    Fav
     */
    app.get('/api/favorites/lists/:id/:maxId?/:count?', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterClient(req.session.passport.user);
      return twitterClient.getFavLists({
        twitterIdStr: req.params.id,
        maxId: req.params.maxId,
        count: req.params.count
      }).then(function(data) {
        return res.json({
          data: data
        });
      })["catch"](function(error) {
        return res.json({
          error: error
        });
      });
    });
    app.post('/api/favorites/create', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterClient(req.session.passport.user);
      return twitterClient.createFav({
        tweetIdStr: req.body.tweetIdStr
      }).then(function(data) {
        return res.json({
          data: data
        });
      })["catch"](function(error) {
        return res.json({
          error: error
        });
      });
    });
    app.post('/api/favorites/destroy', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterClient(req.session.passport.user);
      return twitterClient.destroyFav({
        tweetIdStr: req.body.tweetIdStr
      }).then(function(data) {
        return res.json({
          data: data
        });
      })["catch"](function(error) {
        return res.json({
          error: error
        });
      });
    });
    app.post('/api/statuses/retweet', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterClient(req.session.passport.user);
      return twitterClient.retweetStatus({
        tweetIdStr: req.body.tweetIdStr
      }).then(function(data) {
        return res.json({
          data: data
        });
      })["catch"](function(error) {
        return res.json({
          error: error
        });
      });
    });
    app.post('/api/statuses/destroy', function(req, res) {
      var twitterClient;
      twitterClient = new TwitterClient(req.session.passport.user);
      return twitterClient.destroyStatus({
        tweetIdStr: req.body.tweetIdStr
      }).then(function(data) {
        return res.json({
          data: data
        });
      })["catch"](function(error) {
        return res.json({
          error: error
        });
      });
    });

    /*
     * Config
     */
    app.get('/api/config', function(req, res) {
      return ConfigProvider.findOneById({
        twitterIdStr: req.session.passport.user._json.id_str
      }, function(err, data) {
        console.log('get config: ', data);
        return res.json({
          data: data
        });
      });
    });
    return app.post('/api/config', function(req, res) {
      console.log(req.body);
      return ConfigProvider.upsert({
        twitterIdStr: req.session.passport.user._json.id_str,
        config: req.body.config
      }, function(err, data) {
        console.log('post config: ', data);
        return res.json({
          data: data
        });
      });
    });
  };

}).call(this);
