moment           = require 'moment'
_                = require 'lodash'
path             = require 'path'
chalk            = require 'chalk'
TwitterClient    = require path.resolve 'build', 'lib', 'TwitterClient'
{my}             = require path.resolve 'build', 'lib', 'my'
{twitterUtils}   = require path.resolve 'build', 'lib', 'twitterUtils'
{UserProvider}   = require path.resolve 'build', 'lib', 'model'
{ConfigProvider} = require path.resolve 'build', 'lib', 'model'
settings         = if process.env.NODE_ENV is 'production'
  require path.resolve 'build', 'lib', 'configs', 'production'
else
  require path.resolve 'build', 'lib', 'configs', 'development'


# JSON API
module.exports = (app) ->

  ###
  Middleware
  ###
  app.use '/api/?', (req, res, next) ->
    console.log "======> #{req.originalUrl}"
    unless _.isUndefined(req.session.passport.user)
      next()
    else
      res.redirect '/'


  ###
  APIs
  ###
  (require './api/collect')(app)

  (require './api/config')(app)



  ###
  APIs
  ###
  app.post '/api/download', (req, res) ->
    console.log "\n========> download, #{req.body.url}\n"
    my.loadBase64Data req.body.url
    .then (base64Data) ->
      console.log 'base64toBlob', base64Data.length
      res.json base64Data: base64Data

  ###
  Twitter
  ###
  app.post '/api/findUserById', (req, res) ->
    console.log "\n============> findUserById in API\n"
    UserProvider.findUserById
      twitterIdStr: req.session.passport.user._json.id_str
    , (err, data) ->
      res.json data: data

  # GET リストの情報(公開、非公開)
  app.get '/api/lists/list/:id?/:count?', (req, res) ->
    twitterClient = new TwitterClient(req.session.passport.user)
    twitterClient.getListsList
      twitterIdStr: req.params.id
      count: req.params.count
    .then (data) ->
      console.log '/api/lists/list/:id/:count data.length = ', data.length
      res.json data: data
    .catch (error) ->
      console.log '/api/lists/list/:id/:count error = ', error
      res.json error: error

  # POST リストの作成
  app.post '/api/lists/create', (req, res) ->
    twitterClient = new TwitterClient(req.session.passport.user)
    twitterClient.createLists
      name: req.body.name
      mode: req.body.mode
    .then (data) ->
      console.log '/api/lists/create', data.length
      res.json data: data
    .catch (error) ->
      res.json error: error

  # GET リストのメンバー
  app.get '/api/lists/members/:id?/:count?', (req, res) ->
    twitterClient = new TwitterClient(req.session.passport.user)
    twitterClient.getListsMembers
      listIdStr: req.params.id
      count: req.params.count
    .then (data) ->
      console.log '/api/lists/members/:id/:count data.length = ', data.length
      res.json data: data
    .catch (error) ->
      res.json error: error


  #
  fetchTweet = (req, res, queryType, maxId, config) ->
    # console.log chalk.bgGreen 'fetchTWeet =============> '
    # console.log chalk.green 'maxId =============> '
    # console.log maxId
    # console.log req.params.maxId
    maxId = maxId or req.params.maxId

    params = {}
    switch queryType
      when 'getListsStatuses'
        params =
          listIdStr: req.params.id
          maxId: maxId
          count: req.params.count
          includeRetweet: config.includeRetweet
      when 'getHomeTimeline', 'getUserTimeline'
        params =
          twitterIdStr: req.params.id
          maxId: maxId
          count: req.params.count
          includeRetweet: req.query.isIncludeRetweet or config.includeRetweet
      when 'getFavLists'
        params =
          twitterIdStr: req.params.id
          maxId: req.params.maxId
          count: req.params.count
      else
        res.json data: null
        return

    # console.log chalk.blue 'Before params =============> '
    # console.log "#{queryType} ", params
    twitterClient = new TwitterClient(req.session.passport.user)
    twitterClient[queryType](params)
    .then (tweets) ->
      # console.log chalk.cyan 'tweets.length =============> '
      # console.log "#{queryType} ", tweets.length

      # API限界まで読み終えたとき
      if tweets.length is 0 then res.json data: []

      nextMaxId = my.decStrNum _.last(tweets).id_str
      tweetsNormalized = twitterUtils.normalizeTweets tweets, config
      # console.log "#{queryType} !_.isEmpty tweetsNormalized = ", !_.isEmpty tweetsNormalized

      if !_.isEmpty tweetsNormalized then res.json data: tweetsNormalized

      # console.log chalk.red 'maxId, nextMaxId =============> '
      # console.log maxId
      # console.log nextMaxId
      if maxId is nextMaxId then res.json data: []

      fetchTweet(req, res, queryType, nextMaxId, config)
    .catch (error) ->
      res.json error: error

  # GET リストのタイムラインを取得
  # memo: ConfigProvider.findOneByIdの実行「時間を計測したところ2msとかでした
  app.get '/api/lists/statuses/:id/:maxId?/:count?', (req, res) ->
    ConfigProvider.findOneById
      twitterIdStr: req.session.passport.user._json.id_str
    , (err, data) ->
      # 設定データが未登録
      config = if _.isNull data then {} else JSON.parse(data.configStr)
      fetchTweet(req, res, 'getListsStatuses', null, config)

  # GET タイムラインの情報(home_timeline, user_timeline)
  app.get '/api/timeline/:id/:maxId?/:count?', (req, res) ->
    ConfigProvider.findOneById
      twitterIdStr: req.session.passport.user._json.id_str
    , (err, data) ->
      # 設定データが未登録
      config = if _.isNull data then {} else JSON.parse(data.configStr)
      queryType = if req.params.id is 'home'then 'getHomeTimeline' else 'getUserTimeline'
      fetchTweet(req, res, queryType, null, config)

  # ツイート情報を取得
  app.get '/api/statuses/show/:id', (req, res) ->
    twitterClient = new TwitterClient(req.session.passport.user)
    twitterClient.showStatuses
      tweetIdStr: req.params.id
    .then (data) ->
      res.json data: data
    .catch (error) ->
      res.json error: error

  # user情報を取得
  app.get '/api/users/show/:id/:screenName?', (req, res) ->
    twitterClient = new TwitterClient(req.session.passport.user)
    twitterClient.showUsers
      twitterIdStr: req.params.id
      screenName: req.params.screenName
    .then (data) ->
      res.json data: data
    .catch (error) ->
      res.json error: error


  # GET フォローイングの取得
  app.get '/api/friends/list/:id?/:cursor?/:count?', (req, res) ->
    twitterClient = new TwitterClient(req.session.passport.user)
    twitterClient.getFollowingList
      twitterIdStr: req.params.id
      cursor: req.params.cursor - 0
      count: req.params.count - 0
    .then (data) ->
      res.json data: data
    .catch (error) ->
      res.json error: error


  # POST 仮想フォロー、仮想アンフォロー機能( = Amatsukaリストへの追加、削除)
  app.post '/api/lists/members/create', (req, res) ->
    twitterClient = new TwitterClient(req.session.passport.user)
    twitterClient.createListsMembers
      listIdStr: req.body.listIdStr
      twitterIdStr: req.body.twitterIdStr
    .then (data) ->
      res.json data: data
    .catch (error) ->
      res.json error: error

  app.post '/api/lists/members/create_all', (req, res) ->
    twitterClient = new TwitterClient(req.session.passport.user)
    twitterClient.createAllListsMembers
      listIdStr: req.body.listIdStr
      twitterIdStr: req.body.twitterIdStr
    .then (data) ->
      res.json data: data
    .catch (error) ->
      res.json error: error

  app.post '/api/lists/members/destroy', (req, res) ->
    twitterClient = new TwitterClient(req.session.passport.user)
    twitterClient.destroyListsMembers
      listIdStr: req.body.listIdStr
      twitterIdStr: req.body.twitterIdStr
    .then (data) ->
      res.json data: data
    .catch (error) ->
      res.json error: error


  ###
  Fav
  ###
  app.get '/api/favorites/lists/:id/:maxId?/:count?', (req, res) ->
    fetchTweet(req, res, 'getFavLists', null, null)

  app.post '/api/favorites/create', (req, res) ->
    twitterClient = new TwitterClient(req.session.passport.user)
    twitterClient.createFav
      tweetIdStr: req.body.tweetIdStr
    .then (data) ->
      res.json data: data
    .catch (error) ->
      res.json error: error

  app.post '/api/favorites/destroy', (req, res) ->
    twitterClient = new TwitterClient(req.session.passport.user)
    twitterClient.destroyFav
      tweetIdStr: req.body.tweetIdStr
    .then (data) ->
      res.json data: data
    .catch (error) ->
      res.json error: error


  # POST リツイート、解除
  app.post '/api/statuses/retweet', (req, res) ->
    twitterClient = new TwitterClient(req.session.passport.user)
    twitterClient.retweetStatus
      tweetIdStr: req.body.tweetIdStr
    .then (data) ->
      res.json data: data
    .catch (error) ->
      res.json error: error

  app.post '/api/statuses/destroy', (req, res) ->
    twitterClient = new TwitterClient(req.session.passport.user)
    twitterClient.destroyStatus
      tweetIdStr: req.body.tweetIdStr
    .then (data) ->
      res.json data: data
    .catch (error) ->
      res.json error: error
