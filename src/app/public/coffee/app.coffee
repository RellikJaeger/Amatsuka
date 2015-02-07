angular.module('myApp', [
  'ngRoute'
  'ngAnimate'
  'ngSanitize'
  'infinite-scroll'
  'myApp.controllers'
  'myApp.filters'
  'myApp.services'
  'myApp.factories'
  'myApp.directives'
])
# �褯ʹ���v����ͨ�v���Ȥ��ƶ��x����controller/view�ɤ��餫���ʹ����褦�ˤ���ˤ�
# "constant" ��ʹ�ä���
# �����Ŀ���x�k֫�⹲ͨ�����Ǥ��롣
# �x�k֫�Υ�٥�Ȃ����}�������ʹ�����Ȥ����
.constant 'utils',
  'devices':
    '0': 'PC'
    '1': 'Smart Phone'
    '2': 'Tablet'
    '3': 'Fablet'
    '4': 'Smart Watch'
.run ($rootScope, utils) ->
  # $rootScope�Ή����Ȥ��ƶ��x���뤳�Ȥǡ�view����κ��ӳ�������ܤ�
  $rootScope.utils = utils
.config ($routeProvider, $locationProvider) ->
  $routeProvider.
    when '/',
      templateUrl: 'partials/index'
      controller: 'IndexCtrl'
    .when '/member',
      templateUrl: 'partials/member'
      controller: 'MemberCtrl'
    .when "/logout",
      redirectTo: "/"
    .when "http://127.0.0.1:4040/auth/twitter/callback",
      redirectTo: "/"
    # otherwise redirectTo: '/'
  $locationProvider.html5Mode true
