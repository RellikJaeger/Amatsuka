dir        = './lib/'
_          = require 'lodash'
moment     = require 'moment'
async      = require 'async'
{my}       = require dir + 'my'
{serve}    = require './app/serve'
{settings} = if process.env.NODE_ENV is "production"
  require dir + 'configs/production'
else
  require dir + 'configs/development'

tasks4startUp = [

  (callback) ->

    # Start Server
    my.c "■ Server task start"
    serve null, "Create Server"
    setTimeout (-> callback(null, "Serve\n")), settings.GRACE_TIME_SERVER
    return

  # , (callback) ->

  #   # Cron Server
  #   my.c "■ Cron task start"
  #   resetTimeline null, "Cron"
  #   setTimeout (-> callback(null, "Cron\n")), settings.GRACE_TIME_SERVER
  #   return

]

async.series tasks4startUp, (err, results) ->
  if err
    console.error err
  else
    console.log  "\nall done... Start!!!!\n"
  return

