_                     = require 'lodash'
path                  = require 'path'
TwitterClient         = require path.resolve 'build', 'lib', 'TwitterClient'
{my}                  = require path.resolve 'build', 'lib', 'my'
{IllustratorProvider} = require path.resolve 'build', 'lib', 'model'
{PictProvider}        = require path.resolve 'build', 'lib', 'model'

# TODO: illustratorと分離させる
module.exports = class PictCollection
  constructor: (user, illustratorTwitterIdStr) ->
    @twitterClient = new TwitterClient(user)
    @illustrator = twitterIdStr: illustratorTwitterIdStr
    @illustratorRawData = null
    @illustratorDBData = null
    @pictList = []
    @userTimelineMaxId = null
    @isContinue = true
    @REQUEST_INTERVAL = 5 * 1000

  # For Cron task
  collectProfileAndPicts: ->
    return new Promise (resolve, reject) =>
      console.log 'start collect'
      my.delayPromise @REQUEST_INTERVAL
      .then => @getIllustratorTwitterProfile()
      .then (data) => @setIllustratorRawData(data)
      .then => @getIllustratorRawData()
      .then (illustratorRawData) => @setUserTimelineMaxId(illustratorRawData.status.id_str)
      .then => @normalizeIllustratorData()
      .then => @updateIllustratorData()
      .then (data) => @setIllustratorDBData(data)
      .then => @aggregatePict()
      .then (pickupedPictList) => @updatePictListData(pickupedPictList)
      .then (data) -> return resolve 'Fin'
      .catch (err) -> return reject err

  ###
  Pict
  ###
  aggregatePict: ->
    my.promiseWhile((=>
      @isContinue
    ), =>
      new Promise (resolve, reject) =>
        my.delayPromise @REQUEST_INTERVAL
        .then (data) =>
          @twitterClient.getUserTimeline
            twitterIdStr: @illustrator.twitterIdStr
            maxId: @userTimelineMaxId
            count: '200'
            includeRetweet: false
        .then (data) =>

          # API制限くらったら return
          if _.isUndefined(data)
            @isContinue = false
            reject()

          # 全部読み終えたら(残りがないとき、APIは最後のツイートだけ取得する === 1) return
          if data.length < 2
            @isContinue = false
            resolve()

          @setUserTimelineMaxId my.decStrNum data[data.length - 1].id_str

          # pictList = pictList.concat(tweetListIncludePict)
          tweetListIncludePict = _.chain(data)
          .filter (tweet) -> _.has(tweet, 'extended_entities') and !_.isEmpty(tweet.extended_entities.media) # has pict
          .map (tweet) ->
            o = {}
            o.tweetIdStr = tweet.id_str
            # o.twitterIdStr = tweet.user.id_str
            # o.favNum = tweet.favorite_count
            # o.retweetNum = tweet.retweet_count
            # o.fileName = "#{tweet.user.screen_name}_#{tweet.id_str}"
            o.totalNum = tweet.retweet_count + tweet.favorite_count
            o.mediaUrl = tweet.extended_entities.media[0].media_url_https
            o.mediaOrigUrl = tweet.extended_entities.media[0].media_url_https+':orig'
            o.displayUrl = tweet.extended_entities.media[0].display_url
            o.expandedUrl = tweet.extended_entities.media[0].expanded_url
            return o
          .value()

          # console.log "\n\n=============>"
          # console.log tweetListIncludePict
          # console.log tweetListIncludePict.length

          @pictList = @pictList.concat(tweetListIncludePict)
          resolve()
        return

    ).then (data) =>

      # console.log "\n\nAll =============>"
      # console.log @pictList
      # console.log @pictList.length

      @pickupPictListTop12(@pictList)

  pickupPictListTop12: (pictList) ->
    pictListTop12 = _.chain(pictList)
    .sortBy('totalNum')
    .reverse()
    .slice(0, 12)
    .value()

  updatePictListData: (pickupedPictList) ->
    return new Promise (resolve, reject) =>
      PictProvider.findOneAndUpdate
        postedBy: @illustratorDBData._id
        pictTweetList: pickupedPictList
      , (err, data) ->
        return reject err  if err
        return resolve data

  setUserTimelineMaxId: (maxId) ->
    @userTimelineMaxId = maxId


  ###
  Utils (From Front. TweetService)
  ###
  getExpandedURLFromURL: (entities) ->
    if !_.has(entities, 'url') then return ''
    entities.url.urls

  restoreProfileUrl: ->
    expandedUrlListInUrl = @getExpandedURLFromURL(@illustratorRawData.entities)
    _.each expandedUrlListInUrl, (urls) =>
      @illustratorRawData.url = @illustratorRawData.url.replace(urls.url, urls.expanded_url)


  ###
  Illustrator
  ###
  getIllustratorTwitterProfile: ->
    return new Promise (resolve, reject) =>
      @twitterClient.showUsers twitterIdStr: @illustrator.twitterIdStr
      .then (data) -> return resolve data
      .catch (err) -> return reject err

  setIllustratorRawData: (data) ->
    @illustratorRawData = data

  # Twitterユーザがいないとき、@illustratorRawData.status.id_strが参照できず、エラーが生じて落ちる。
  # ちゃんとrejectionがハンドルできる形にするためPromiseで囲う
  getIllustratorRawData: ->
    return new Promise (resolve, reject) =>
      if @illustratorRawData.status?.id_str?
        return resolve @illustratorRawData
      return reject 'getIllustratorRawData Error ::'

  setIllustratorDBData: (data) ->
    @illustratorDBData = data

  #getIllustratorDBData: ->


  # Setの方が統一感ある? 意味的には正規化なんだけど
  normalizeIllustratorData: ->
    @restoreProfileUrl()

    @illustrator =
      twitterIdStr: @illustratorRawData.id_str
      name: @illustratorRawData.name
      screenName: @illustratorRawData.screen_name
      icon: @illustratorRawData.profile_image_url_https
      url: @illustratorRawData.url
      description: @illustratorRawData.description

  getIllustratorData: ->
    @illustrator

  updateIllustratorData: ->
    return new Promise (resolve, reject) =>
      IllustratorProvider.findOneAndUpdate
        illustrator: @illustrator
      , (err, data) ->
        return reject err  if err
        return resolve data