(function() {
  exports.serve = function() {
    var app, http, path, settings;
    http = require('http');
    path = require('path');
    settings = require(path.resolve('build', 'lib', 'configs', 'settings')).settings;
    app = module.exports = (function() {
      var MongoStore, bodyParser, cacheOptions, compression, cookieParser, env, express, fs, methodOverride, morgan, opbeat, options, passport, session, stream;
      express = require('express');
      bodyParser = require('body-parser');
      cookieParser = require('cookie-parser');
      methodOverride = require('method-override');
      morgan = require('morgan');
      passport = require('passport');
      session = require('express-session');
      compression = require('compression');
      opbeat = require('opbeat');
      MongoStore = require('connect-mongo')(session);
      options = {
        secret: settings.COOKIE_SECRET,
        saveUninitialized: true,
        resave: false,
        store: new MongoStore({
          url: settings.MONGODB_URL,
          collection: 'sessions',
          clear_interval: 3600 * 12,
          auto_reconnect: true
        })
      };
      cacheOptions = {
        dotfiles: 'ignore',
        etag: false,
        extensions: ['htm', 'html', 'css', 'js', 'jpg', 'png', 'gif', 'mp4'],
        index: false,
        maxAge: 0,
        redirect: false,
        setHeaders: function(res, path, stat) {
          res.set({
            'x-timestamp': Date.now()
          });
        }
      };
      app = express();
      app.disable('x-powered-by');
      app.set('port', process.env.PORT || settings.PORT);
      app.set('views', __dirname + '/views');
      app.set('view engine', 'jade');
      app.use(morgan('dev'));
      app.use(cookieParser());
      app.use(bodyParser.json({
        limit: '50mb'
      }));
      app.use(bodyParser.urlencoded({
        extended: true,
        limit: '50mb'
      }));
      app.use(methodOverride());
      app.use(session(options));
      app.use(compression());
      app.use(passport.initialize());
      app.use(passport.session());
      app.use(express["static"](path.join(__dirname, 'public'), cacheOptions));
      env = process.env.NODE_ENV || 'development';
      if (env === 'development') {
        fs = require('fs');
        stream = fs.createWriteStream(__dirname + '/log.txt', {
          flags: 'a'
        });
        app.locals.pretty = true;
        app.use(function(err, req, res, next) {
          res.status(err.status || 500);
          return res.json({
            message: err.message,
            error: err
          });
        });
      }
      if (env === 'production') {
        app.locals.pretty = false;
        app.use(opbeat.middleware.express());
      }
      console.log(settings);
      return app;
    })();
    (function() {
      var ModelFactory, TwitterStrategy, my, passport;
      passport = require('passport');
      TwitterStrategy = require('passport-twitter').Strategy;
      ModelFactory = require(path.resolve('build', 'model', 'ModelFactory'));
      my = require(path.resolve('build', 'lib', 'my')).my;
      passport.serializeUser(function(user, done) {
        done(null, user);
      });
      passport.deserializeUser(function(obj, done) {
        done(null, obj);
      });
      passport.use(new TwitterStrategy({
        consumerKey: settings.TW_CK,
        consumerSecret: settings.TW_CS,
        callbackURL: settings.CALLBACK_URL
      }, function(token, tokenSecret, profile, done) {
        var user;
        console.log('User profile = ', profile);
        profile.twitter_token = token;
        profile.twitter_token_secret = tokenSecret;
        user = {
          twitterIdStr: profile._json.id_str,
          name: profile.username,
          screenName: profile.displayName,
          icon: profile._json.profile_image_url_https,
          url: profile._json.url,
          accessToken: token,
          accessTokenSecret: tokenSecret,
          maoToken: my.createHash(profile._json.id_str + settings.MAO_TOKEN_SALT)
        };
        ModelFactory.create('user').findOneAndUpdate({
          user: user
        }).then(function(data) {
          return done(null, profile);
        })["catch"](function(err) {
          return console.log(err);
        });
      }));
      app.get('/auth/twitter', passport.authenticate('twitter'));
      app.get('/auth/twitter/callback', passport.authenticate('twitter', {
        successRedirect: '/',
        failureRedirect: '/'
      }));
      (require('./routes/api'))(app);
      return (require('./routes/routes'))(app);
    })();
    return (function() {
      var srv;
      return srv = app.listen(app.get('port'), function() {
        return console.log('Express server listening on port ' + app.get('port'));
      });
    })();
  };

}).call(this);
