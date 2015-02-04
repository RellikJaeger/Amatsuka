# Factories
angular.module "myApp.factories", []
  .factory 'Tweets', ($http, TweetService) ->

    class Tweets
      constructor: (items, list, maxId) ->
        @busy  　= false
        @isLast　= false
        @items 　= items
        @list  　= list
        @maxId 　= maxId

      nextPage: ->
        console.log @busy
        console.log @isLast
        return if @busy or @isLast
        @busy = true
        TweetService.getListsStatuses(listIdStr: @list.id_str, maxId: @maxId)
        .then (data) =>
          console.table data.data
          if _.isEmpty(data.data)
            @isLast = true
            @busy = false
            return

          @maxId = TweetService.decStrNum(_.last(data.data).id_str)
          items = TweetService.filterIncludeImage data.data
          _.each items, (item) =>
            item.text = TweetService.activateLink(item.text)
            item.time =
              TweetService.fromNow(TweetService.get(item, 'tweet.created_at', false))
            item.user.profile_image_url =
              TweetService.iconBigger(item.user.profile_image_url)
            @items.push item
          @busy = false

    Tweets