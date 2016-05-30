# Viewwe
# KeyCommander
# DataManager
angular.module "myApp.factories"
  .factory 'ZoomImageViewer', (GetterImageInfomation) ->
    class ZoomImageViewer

      constructor: ->
        @imageLayer = angular.element(document).find('.image-layer')
        containerHTML = """
          <div class="image-layer__container">
            <img class="image-layer__img"/>
            <div class="image-layer__loading">
              <img src="./images/loaders/tail-spin.svg" />
            </div>
          </div>

          """
        @imageLayer.html containerHTML

        # 画面全体をオーバーレイで覆う
        @imageLayer.addClass('image-layer__overlay')

        @imageLayerImg = angular.element(document).find('.image-layer__img')
        @imageLayerLoading = angular.element(document).find('.image-layer__loading')

      getImageLayerImg: ->
        return @imageLayerImg

      setImageAndStyle: (imgElement) ->
        direction = GetterImageInfomation.getWideDirection(imgElement)
        imgElement.addClass("image-layer__img-#{direction}-wide")

      pipeLowToHighImage: (from, to) ->
        @imageLayerLoading.show()
        @imageLayerImg.hide()
        @imageLayerImg.removeClass()

        @imageLayerImg
        .attr 'src', from
        .load =>
          console.log '-> Middle'
          @imageLayerLoading.hide()
          @setImageAndStyle(@imageLayerImg)
          @imageLayerImg.fadeIn(1)

          # loadの∞ループ回避
          @imageLayerImg.off 'load'

          @imageLayerImg
          .attr 'src', to
          .load =>
            console.log '-> High'
            # @setImageAndStyle(@imageLayerImg, @html)
            @imageLayerImg.fadeIn(1)


      cleanup: ->
        @imageLayerLoading.remove()
        @imageLayer.removeClass('image-layer__overlay')

    ZoomImageViewer