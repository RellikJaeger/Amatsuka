# Services
angular.module "myApp.services"
  .service "MaoService", ($http) ->

    findByMaoTokenAndDate: (qs) ->
      $http.get "/api/mao?#{qs}"
