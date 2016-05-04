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

  .directive 'downloadFromUrl', ($q, toaster, DownloadService) ->
    restrict: 'A'
    link: (scope, element, attrs) ->
      element.on 'click', (event) ->

        # findページでダウンロードボタンが押された場合は単発固定 + 文字列で渡される よってJSON.parseすると ["h", "t", ~]の形になり以降の処理に失敗する
        # その他からは"[~]"の形で渡されるため、処理を分岐させる。
        urlList = if attrs.url.indexOf('[') is -1 then [attrs.url] else JSON.parse(attrs.url)
        promises = []

        toaster.pop 'wait', "Now Downloading ...", '', 0, 'trustedHtml'
        urlList.forEach (url, idx) ->
          promises.push DownloadService.exec(url, attrs.filename, idx)

        $q.all promises
        .then (datas) ->
          toaster.clear()
          toaster.pop 'success', "Finished Download", '', 2000, 'trustedHtml'

  .directive 'icNavAutoclose', ->
    console.log 'icNavAutoclose'
    (scope, elm, attrs) ->
      collapsible = $(elm).find('.navbar-collapse')
      visible = false

      collapsible.on 'show.bs.collapse', ->
        visible = true
        return

      collapsible.on 'hide.bs.collapse', ->
        visible = false
        return

      $(elm).find('a').each (index, element) ->
        $(element).click (e) ->
          return if e.target.className.indexOf('dropdown-toggle') isnt -1
          if visible and 'auto' == collapsible.css('overflow-y')
            collapsible.collapse 'hide'
          return
        return
      return

  .directive 'clearLocalStorage', (toaster) ->
    restrict: 'A'
    link: (scope, element, attrs) ->
      element.on 'click', (event) ->
        toaster.pop 'wait', "Now Clearing ...", '', 0, 'trustedHtml'
        window.localStorage.clear()
        toaster.clear()
        toaster.pop 'success', "Finished clearing the list data", '', 2000, 'trustedHtml'
