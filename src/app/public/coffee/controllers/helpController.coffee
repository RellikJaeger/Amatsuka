angular.module "myApp.controllers"
  .controller "HelpCtrl", (
    $scope
    $location
    AuthService
    ) ->
  if _.isEmpty AuthService.user then $location.path '/'
