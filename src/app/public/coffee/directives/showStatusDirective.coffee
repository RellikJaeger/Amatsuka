angular.module 'myApp.directives'
  .directive 'showStatuses', ($compile, GetterImageInfomation, TweetService, WindowScrollableSwitcher, ZoomImageViewer) ->
    restrict: 'A'
    link: (scope, element, attrs) ->
      element.on 'click', (event) ->
        WindowScrollableSwitcher.disableScrolling()

        # TODO: Status?の部分をviewer同様、クラス化したい。
        tweet = null
        imgIdx = 0

        zoomImageViewer = new ZoomImageViewer()
        zoomImageViewer.showImage(attrs.imgSrc)

        imageLayer          = angular.element(document).find('.image-layer')
        imageLayerContainer = angular.element(document).find('.image-layer__container')
        next                = angular.element(document).find('.image-layer__next')
        prev                = angular.element(document).find('.image-layer__prev')

        TweetService.showStatuses(tweetIdStr: attrs.tweetIdStr)
        .then (data) ->
          tweet = data.data
          bindEvents()
          showTweetInfomation(tweet, imgIdx);

        showTweetInfomation = (tweet, imgIdx) ->
          imageLayerCaptionHtml = """
            <div class="image-layer__caption">
              <div class="timeline__post--footer">
                <div class="timeline__post--footer--contents">
                  <div class="timeline__post--footer--contents--controls">
                    <a href="#{tweet.entities.media[imgIdx].expanded_url}" target="_blank">
                      <i class="fa fa-twitter icon-twitter"></i>
                    </a>
                    <i class="fa fa-retweet icon-retweet" tweet-id-str="#{tweet.id_str}" retweeted="#{tweet.retweeted}" retweetable="retweetable"></i>
                    <i class="fa fa-heart icon-heart" tweet-id-str="#{tweet.id_str}" favorited="#{tweet.favorited}" favoritable="favoritable"></i>
                    <a><i class="fa fa-download" data-url="#{tweet.extended_entities.media[imgIdx].media_url_https}:orig" filename="#{tweet.user.screen_name}_#{tweet.id_str}" download-from-url="download-from-url"></i></a>
                  </div>
                </div>
              </div>
            </div>
          """

          # 読み込み前に拡大画像を閉じた場合はcaptionタグを表示させない
          return if _.isEmpty(imageLayer.html())
          item = $compile(imageLayerCaptionHtml)(scope).hide().fadeIn(300)
          imageLayer.append(item)

        getImgIdx = (dir, originalIdx) ->
          console.log 'before originalIdx = ', originalIdx
          if dir is 'next' then return (originalIdx + 1) % tweet.extended_entities.media.length
          if dir is 'prev' then return if (originalIdx - 1) < 0 then tweet.extended_entities.media.length - 1 else (originalIdx - 1)
          # 'active'
          # return originalIdx % tweet.extended_entities.media.length

        switchImage = (dir) ->
          console.log tweet
          # return if tweet.extended_entities.media.length < 2
          imgIdx = getImgIdx(dir, imgIdx)
          src = tweet.extended_entities.media[imgIdx].media_url_https
          zoomImageViewer.showImage(src)


        bindEvents = ->
          # ClickEvent
          # オーバーレイ部分をクリックしたら生成した要素は全て削除する
          imageLayerContainer.on 'click', -> cleanup()


          # KeyEvent
          Mousetrap.bind 'f', -> angular.element(document).find('.image-layer__caption .icon-heart').click()
          Mousetrap.bind 'r', -> angular.element(document).find('.image-layer__caption .icon-retweet').click()
          Mousetrap.bind 'd', -> angular.element(document).find('.image-layer__caption .fa-download').click()
          Mousetrap.bind ['esc', 'q'], -> cleanup()

          return if tweet.extended_entities.media.length < 2

          # ClickEvent
          next.on 'click', -> switchImage('next')
          prev.on 'click', -> switchImage('prev')

          # KeyEvent
          Mousetrap.bind ['left', 'k'], -> switchImage('prev')
          Mousetrap.bind ['right', 'j'], -> switchImage('next')

          # ScrollEvent
          imageLayerContainer.on 'wheel', (e) ->
            # e.originalEvent.wheelDelta >= 0  === Scroll up
            dir = if e.originalEvent.wheelDelta >= 0 then 'prev' else 'next'
            switchImage(dir)

        cleanup = ->
          Mousetrap.unbind ['left', 'right', 'esc', 'd', 'f', 'j', 'k', 'q', 'r']

          imageLayer.html ''
          imageLayerContainer.html ''

          next.remove()
          prev.remove()

          WindowScrollableSwitcher.enableScrolling()

          zoomImageViewer.cleanup()
          zoomImageViewer = null