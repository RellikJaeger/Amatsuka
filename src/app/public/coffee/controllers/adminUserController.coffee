angular.module "myApp.controllers"
  .controller "AdminUserCtrl", (
    $scope
    $rootScope
    $location
    $log
    AuthService
    ) ->
  $scope.isLoaded = false
  $scope.isAuthenticated = AuthService.status.isAuthenticated

  # ログイン済みで、別ページからの遷移
  if AuthService.status.isAuthenticated
    $scope.isLoaded = true
    return

  AuthService.isAuthenticated()
    .success (data) ->

      # 未ログインならログインページを表示
      if _.isNull data.data
        $scope.isLoaded = true
        $location.path '/'
        return

      AuthService.status.isAuthenticated = true
      $scope.isAuthenticated = AuthService.status.isAuthenticated

      AuthService.user = data.data
      $scope.user = data.data

      # 準備OK
      $scope.isLoaded = true

    .error (status, data) ->
      console.log status
      console.log data
