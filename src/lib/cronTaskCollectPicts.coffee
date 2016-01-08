path                  = require 'path'
_                     = require 'lodash'
Promise               = require "bluebird"
PictCollection        = require path.resolve 'build', 'lib', 'PictCollection'
{IllustratorProvider} = require path.resolve 'build', 'lib', 'model'
{settings}            = if process.env.NODE_ENV is 'production'
  require path.resolve 'build', 'lib', 'configs', 'production'
else
  require path.resolve 'build', 'lib', 'configs', 'development'

exports.cronTaskCollectPicts = ->
  IllustratorProvider.find()
  .then (profileList) ->
    console.log profileList.length

    user =
      _json:
        id_str: settings.TW_ID_STR
      twitter_token: settings.TW_AT
      twitter_token_secret: settings.TW_AS

    promises = []
    profileList.forEach (profile, idx) ->
      pictCollection = new PictCollection(user, profile.twitterIdStr, idx)
      promises.push pictCollection.collectProfileAndPicts()
    Promise.all promises
    .then (resultList) ->
      console.log 'Succeeded!'
      return
    .catch (err) ->
      console.error 'Failed.', err
      return
