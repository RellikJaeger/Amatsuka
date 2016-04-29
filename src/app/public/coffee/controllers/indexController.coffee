angular.module "myApp.controllers"
  .controller "IndexCtrl", (
    $scope
    $location
    AuthService
    TweetService
    ListService
    ConfigService
    Tweets
    ) ->
  return if _.isEmpty AuthService.user

  $scope.listIdStr  = ''
  $scope.isLoaded   = false
  $scope.layoutType = 'grid'
  $scope.message    = 'リストデータの確認中'

  # todo: 後で消す
  # 何かの手違いで'amatsukaList'に文字列型のundefinedが格納されてしまい、
  # それをJSON.pasrseするとエラーが出る。それを回避するための処理。
  # 代替方法があればそっちにする。
  amatsukaList = localStorage.getItem('amatsukaList')
  amatsukaList = if amatsukaList is 'undefined' then {} else JSON.parse amatsukaList

  amatsukaFollowList = localStorage.getItem('amatsukaFollowList')
  amatsukaFollowList = if amatsukaFollowList is 'undefined' then [] else JSON.parse amatsukaFollowList

  if _.isEmpty amatsukaList then window.localStorage.clear()

  ListService.amatsukaList =
    data: amatsukaList
    member: amatsukaFollowList


  # localStorageに保存されているAmatsukaListが別のアカウントかどうかチェックする
  ListService.isSameAmatsukaList()
  .then (_isSameAmatsukaList) ->
    console.log '=> _isSameAmatsukaList = ', _isSameAmatsukaList

    if _isSameAmatsukaList
      $scope.tweets = new Tweets([])
      do ->
        ListService.update()
        .then (data) ->
          console.log 'ok'
        return
      return

    console.log '=> false _isSameAmatsukaList'

    $scope.message = 'リストデータの更新中'
    ListService.update()
    .then (data) ->
      console.log '==> update() then data = ', data

      # 別のユーザで再ログインしたとき
      $scope.tweets = new Tweets([])
      return

    .catch (error) ->
      console.log '==> update() catch error = ', error

      # ログインしたユーザがAmatsuka Listを未作成(初ログイン)のとき
      $scope.message = 'リストを作成中'
      ListService.init()
      .then (data) ->
        console.log '===> init() then data ', data

        #設定データを初期化
        do ConfigService.init

        # 初期化した設定データをデータベースに格納
        do ConfigService.save2DB

      .then (data) ->
        console.log '===> ConfigService then data = ', data
        $scope.tweets = new Tweets([])

    .finally ->
      console.log '==> update() finally'
      $scope.message = ''

  .catch (error) ->
    console.log '=> catch isSameAmatsukaList error = ', error
  .finally ->
    console.log '=> isSameAmatsukaList() finally'
    ConfigService.getFromDB().then (data) ->
      $scope.config = data
      console.log '==> finally config = ', $scope.config
    $scope.listIdStr = ListService.amatsukaList.data.id_str
    $scope.isLoaded  = true
    $scope.message   = ''
    console.log '=> 終わり'
    return


  $scope.$on 'addMember', (event, args) ->
    console.log 'index addMember on ', args
    TweetService.applyFollowStatusChange $scope.tweets.items, args
    return

  $scope.$on 'resize::resize', (event, args) ->
    console.log 'index resize::resize on ', args.layoutType
    $scope.$apply ->
      $scope.layoutType = args.layoutType
      return
    return