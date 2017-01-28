path             = require 'path'
TwitterClient    = require path.resolve 'build', 'lib', 'TwitterClient'

# 汎用化したver
module.exports = (app) ->

  app.get '/api/twitter', (req, res, next) ->
    console.log 'GET /api/twitter', req.query
    twitterClient = new TwitterClient(req.session.passport.user)
    twitterClient.getViaAPI method: req.query.method, type: req.query.type, params: req.query
    .then (data) ->
      res.send data
    .catch (err) ->
      next err
      # res.status(429).send error

  app.post '/api/twitter', (req, res, next) ->
    console.log 'POST /api/twitter', req.body
    twitterClient = new TwitterClient(req.session.passport.user)
    twitterClient.postViaAPI method: req.body.method, type: req.body.type, params: req.body
    .then (data) ->
      res.send data
    .catch (err) ->
      next err
    # .catch (error) ->
      # res.status(429).send error