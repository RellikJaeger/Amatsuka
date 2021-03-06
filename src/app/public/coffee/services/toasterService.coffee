angular.module "myApp.services"
  .service 'ToasterService', (toaster) ->
    success: (notify) ->
      console.log notify.title
      toaster.pop 'success', notify.title, notify.text, 2000, 'trustedHtml'

    warning: (notify) ->
      console.log notify.title
      toaster.pop 'warning', notify.title, notify.text, 2000, 'trustedHtml'