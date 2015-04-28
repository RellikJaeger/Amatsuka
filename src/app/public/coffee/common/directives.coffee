# Directives
angular.module "myApp.directives", []
  .directive 'dotLoader', () ->
      restrict: 'E'
      template: '''
        <div class="wrapper">
          <div class="dot"></div>
          <div class="dot"></div>
          <div class="dot"></div>
        </div>
      '''

  .directive "imgPreload", ->
    restrict: "A"
    link: (scope, element, attrs) ->
      element.on("load", ->
        element.addClass "in"
        return
      ).on "error", ->
      return

  .directive "scrollOnClick", ->
    restrict: "A"
    scope:
      scrollTo: "@"
    link: (scope, element, attrs) ->
      element.on 'click', ->
        $('html, body').animate
          scrollTop: $(scope.scrollTo).offset().top, "slow"

  .directive 'resize', ($timeout, $rootScope, $window) ->
    link: ->
      timer = false
      angular.element($window).on 'load resize', (e) ->
        if timer then $timeout.cancel timer

        timer = $timeout ->

          # ウィンドウのサイズを取得
          html = angular.element(document).find('html')
          cW = html[0].clientWidth
          console.log 'broadCast resize ', cW

          # ウィンドウのサイズを元にビューを切り替える
          # 2カラムで表示できる限界が700px
          layoutType = if cW < 700 then 'list' else 'grid'

          $rootScope.$broadcast 'resize::resize', layoutType: layoutType

        , 200
        return



  .directive "zoomImage", ($rootScope, TweetService) ->
    restrict: 'A'
    link: (scope, element, attrs) ->
      html =  ''

      # 画像プリロード(押してから表示するより体感速度的に高速)
      element.on 'mouseenter', ->
        imageLayer = angular.element(document).find('.image-layer')
        html = """
          <img
            src="#{attrs.imgSrc}:orig"
            class="image-layer__img image-layer__img--hidden" />
          """
        imageLayer.html html

      element.on 'click', ->

        # windowのサイズを取得
        html = angular.element(document).find('html')

        imageLayer = angular.element(document).find('.image-layer')
        imageLayer.addClass('image-layer__overlay')

        imageLayerImg = angular.element(document).find('.image-layer__img')
        imageLayerImg.removeClass('image-layer__img--hidden')
        return unless imageLayerImg[0].naturalHeight?

        # 画面に綺麗に収まるようimgのサイズを設定する処理
        # XXX:
        # スマホだとhoverイベントをキャッチできず 画像のサイズが分からないのでPCだけの機能とする、
        # TODO:
        # ngTouchとか使ってスマホにも対応。
        h = imageLayerImg[0].naturalHeight
        w = imageLayerImg[0].naturalWidth
        dirction = if h > w then 'h' else 'w'

        # 画像の縦横比から調整する
        console.log h, w
        h_w_percent = h / w * 100
        if 50 < h_w_percent < 75
          # 横長
          console.log '横長', h_w_percent
          dirction = 'w'
        else if 100 <= h_w_percent < 125
          # 縦長
          console.log '縦長', h_w_percent
          dirction = 'h'

        # 画面サイズから調整する
        cH = html[0].clientHeight
        cW = html[0].clientWidth
        cH_cW_percent = cH / cW * 100
        console.log 'cH_cW_percent = ', cH_cW_percent
        if cH_cW_percent < 75
          # 横長
          console.log 'c 横長', cH_cW_percent
          dirction = 'h'
        else if 125 < cH_cW_percent
          # 縦長
          console.log 'c 縦長', cH_cW_percent
          dirction = 'w'

        imageLayerImg.addClass("image-layer__img-#{dirction}-wide")

        imageLayer.on 'click', ->
          imageLayer.html ''
          imageLayer.removeClass('image-layer__overlay')

  .directive 'downloadFromUrl', (DownloadService, ConvertService) ->
    restrict: 'A'
    link: (scope, element, attrs) ->
      element.on 'click', (event) ->
        DownloadService.exec(attrs.url)
        .success (data) ->
          blob = ConvertService.base64toBlob data.base64Data
          ext = /media\/.*\.(png|jpg|jpeg):orig/.exec(attrs.url)[1]
          filename = "#{attrs.filename}.#{ext}"
          saveAs blob, filename


