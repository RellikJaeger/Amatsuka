path       = require 'path'
gulp       = require 'gulp'
$          = do require 'gulp-load-plugins'
ngAnnotate = require 'gulp-ng-annotate'
config     = require('../config').coffee_app_public
optFile    = path.resolve 'config.json'


gulp.task 'coffee_app_public', ->
  gulp.src config.src
    .pipe $.plumber()
    .pipe $.cached('coffee_app_public')
    .pipe $.coffeelint(optFile: optFile)
    .pipe $.coffeelint.reporter()
    .pipe $.coffee(bare: true)
    .pipe $.remember('coffee_app_public')
    .pipe $.concat('main.js')
    .pipe ngAnnotate()
    .pipe gulp.dest config.dest
    .pipe $.stripDebug()
    .pipe $.rename suffix: '.min'
    .pipe $.uglify()
    .pipe gulp.dest config.dest
    .pipe $.gzip()
    .pipe gulp.dest config.dest
    .pipe $.notify 'coffee_app_public task complete'
