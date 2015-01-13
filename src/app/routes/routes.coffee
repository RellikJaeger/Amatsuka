dir              = '../../lib/'
moment           = require 'moment'
_                = require 'lodash'
{Promise}        = require 'es6-promise'
my               = require dir + 'my'
{twitterTest}    = require dir + 'twitter-test'
{UserProvider}   = require dir + 'model'
settings         = if process.env.NODE_ENV is 'production'
  require dir + 'configs/production'
else
  require dir + 'configs/development'

module.exports = (app) ->

  app.get '/logout', (req, res) ->
    return  unless _.has(req.session, 'id')
    req.logout()
    req.session.destroy()
    res.redirect "/"
    return

  # serve index and view partials
  app.get '/', (req, res) ->
    res.render "index"
    return

  app.get '/partials/:name', (req, res) ->
    name = req.params.name
    res.render "partials/" + name
    return

  # JSON API
  app.get '/api/isAuthenticated', (req, res) ->
    sessionUserData = null
    unless _.isUndefined req.session.passport.user
      sessionUserData = req.session.passport.user
    res.json data: sessionUserData

  app.post '/api/findUserById', (req, res) ->
    console.log "\n============> findUserById in API\n"
    UserProvider.findUserById
      twitterIdStr: req.body.twitterIdStr
    , (err, data) ->
      res.json data: data

  # APIの動作テスト。後で消す
  app.post '/api/twitterTest', (req, res) ->
    console.log "\n============> twitterTest in API\n"
    console.log "req.body.user = ", req.body.user
    twitterTest(req.body.user)
    .then (data) ->
      console.log 'routes data = ', data
      res.json data: data

  #　まだ動かん
  app.get '/api/timeline/:type/:id', (req, res) ->
    console.log "\n============> get/timeline/:type/:id in API\n"
    PostProvider.findUserById
      twitterIdStr: req.params.id
    , (err, data) ->
      console.log data
      res.json data: data

  # redirect all others to the index (HTML5 history)
  app.get '*', (req, res) ->
    res.render "index"
    return
