angular.module "myApp.factories"
  .factory 'Tweets', ($http, $q, $rootScope, ConfigService, ToasterService, TweetService, ListService) ->

    class Tweets
      constructor: (@items, @maxId = undefined, @type, @twitterIdStr = null) ->
        @busy   = false
        @isLast = false
        @method = null
        @count = 40
        ConfigService.get()
        .then (data) => @count = data.tweetNumberAtOnce or 40


      normalizeTweet: (data) =>
        return new Promise (resolve, reject) =>
          if data.error? then reject data.error
          if _.isEmpty(data.data) then return reject statusCode: 10100
          @maxId           = TweetService.decStrNum _.last(data.data).id_str
          itemsNormalized  = TweetService.normalizeTweets data.data, ListService.amatsukaList.member
          resolve itemsNormalized

      assignTweet: (tweets) =>
        return new Promise (resolve, reject) =>
          if _.isEmpty tweets then return reject statusCode: 100110

          do =>
            # console.time('assignTweet') assignTweet: 0.108ms
            $q.all tweets.map (tweet) =>
              [@items][0].push tweet
            .then (result) =>
              @busy = false
              setTimeout((-> lozad().observe()), 100)
            return
          return

      checkError: (statusCode) =>
        console.log 'Tweetes', statusCode
        switch statusCode
          when 429 # Rate limit exceeded
            ToasterService.warning title: 'ツイート取得API制限', text: '15分お待ちください'
          when 10100 # 最後まで読み込み終了
            @isLast = true
            @busy = false
            ToasterService.success title: '全ツイート取得完了', text: '全て読み込みました'
          when 10110 # 取得するツイートが0
            @busy = false
        return


      nextPage: ->
        console.log new Date()
        console.log @busy
        console.log @isLast
        if @busy or @isLast
          return 
          
        if @type is 'user_timeline'
          @method = TweetService.getUserTimeline(twitterIdStr: @twitterIdStr, maxId: @maxId, count: @count)
        else if @type is 'like'
          @method = TweetService.getFavLists(twitterIdStr: @twitterIdStr, maxId: @maxId, count: @count)
        else
          @method = TweetService.getListsStatuses(listIdStr: ListService.amatsukaList.data.id_str, maxId: @maxId, count: @count)

        @busy = true

        do =>
          @method
          .then (data) => @normalizeTweet data
          .then (itemsNormalized) => @assignTweet itemsNormalized
          .catch (response) => @checkError response.statusCode
          return

    Tweets
