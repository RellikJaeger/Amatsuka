angular.module('myApp', [
  'ngRoute'
  'ngAnimate'
  'ngSanitize'
  'myApp.controllers'
  'myApp.filters'
  'myApp.services'
  'myApp.directives'
])
# よく使う関数を共通関数として定義し、controller/viewどちらからも使えるようにするには
# "constant" を使用する
# 入力項目の選択肢も共通化ができる。
# 選択肢のラベルと値を複数画面で使うことも可能
.constant 'utils',
  'devices':
    '0': 'PC'
    '1': 'Smart Phone'
    '2': 'Tablet'
    '3': 'Fablet'
    '4': 'Smart Watch'
.run ($rootScope, utils) ->
  # $rootScopeの変数として定義することで、viewからの呼び出しを可能に
  $rootScope.utils = utils
.config ($routeProvider, $locationProvider) ->
  $routeProvider.
    when '/',
      templateUrl: 'partials/index'
      controller: 'IndexCtrl'
    .when "/logout",
      redirectTo: "/"
    .when "http://127.0.0.1:4321/auth/twitter/callback",
      redirectTo: "/"
    # otherwise redirectTo: '/'
  $locationProvider.html5Mode true
