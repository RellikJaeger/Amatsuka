_         = require 'lodash'
util      = require 'util'
moment    = require 'moment'
Promise   = require 'bluebird'

twitterUtils = ->

  isRT: (tweet) ->
    _.has tweet, 'retweeted_status'

  get: (tweet, key, isRT) ->
    t = if isRT then tweet.retweeted_status else tweet
    switch key
      when 'description' then t.user.description
      when 'display_url' then t.entities?.media?[0].display_url
      when 'entities' then t.entities
      when 'expanded_url' then t.entities?.media?[0].expanded_url
      when 'followers_count' then t.user.followers_count
      when 'friends_count' then t.user.friends_count
      when 'hashtags'
        t.entities?.hashtags # TODO: 一個しか取れない
      when 'media_url'
        _.map t.extended_entities.media, (media) -> media.media_url
      when 'media_url_https'
        _.map t.extended_entities.media, (media) -> media.media_url_https
      when 'media_url:orig'
        _.map t.extended_entities.media, (media) -> media.media_url+':orig'
      when 'media_url_https:orig'
        _.map t.extended_entities.media, (media) -> media.media_url_https+':orig'
      when 'video_url' # videoは一件のみ投稿可能
        t.extended_entities?.media[0]?.video_info?.variants[0].url
      when 'name' then t.user.name
      when 'profile_banner_url' then t.user.profile_banner_url
      when 'profile_image_url' then t.user.profile_image_url
      when 'profile_image_url_https' then t.user.profile_image_url_https
      when 'statuses_count' then t.user.statuses_count
      when 'screen_name' then t.user.screen_name
      when 'source' then t.source
      when 'text' then t.text
      when 'timestamp_ms' then t.timestamp_ms
      when 'tweet.created_at' then t.created_at
      when 'tweet.favorite_count' then t.favorite_count
      when 'tweet.retweet_count' then t.retweet_count
      when 'tweet.id_str' then t.id_str
      when 'tweet.lang' then t.lang
      when 'user.created_at' then t.user.created_at
      when 'user.id_str' then t.user.id_str
      when 'user.favorite_count' then t.favorite_count
      when 'user.retweet_count' then t.retweet_count
      when 'user.lang' then t.user.lang
      when 'user.url' then t.user.url
      else null

  # normalizeTweetsStr: (tweets, config = {}) ->

  normalizeTweets: (tweets, config = {}) ->
    config.ngUsername or= []
    config.ngWord or= []
    config.retweetLowerLimit or= 0
    config.favLowerLimit or= 0
    # console.log(config)

    _.reject tweets, (tweet) =>

      # tweetStr は Maoによって収集したツイート、それ以外はtweet
      tweet = if _.has(tweet, 'tweetStr') then JSON.parse(tweet.tweetStr) else tweet

      # tweetを最初にgetして使いまわす方法
      tweet               = if @isRT(tweet) then tweet.retweeted_status else tweet
      includeNgUser       = config.ngUsername.some (element, index) => tweet.user.screen_name.indexOf(element.text) isnt -1
      includeNgWord       = config.ngWord.some (element, index) => tweet.text.indexOf(element.text) isnt -1
      isRetweetLowerLimit = tweet.retweet_count < config.retweetLowerLimit
      isFavLowerLimit     = tweet.favorite_count < config.favLowerLimit
      isOnlyTextTweet     = (!_.has(tweet, 'extended_entities') or _.isEmpty(tweet.extended_entities.media))

      includeNgUser or includeNgWord or isRetweetLowerLimit or isFavLowerLimit or isOnlyTextTweet

exports.twitterUtils = twitterUtils()