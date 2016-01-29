'use strict'

$ = require('gulp-load-plugins')(
  lazy: true
  camelize: true
)

browserSync =     require('browser-sync')
del =             require('del')
es =              require('event-stream')
fs =              require('fs')
gulp =            require('gulp')
path =            require('path')
runSequence =     require('run-sequence').use(gulp)

SRC =
  ASSETS:       [ 'src/assets/**/*' ]
  COFFEE:       [ 'src/js/main/**/*.coffee' ]
  EXTERNAL_JS:  [ 'src/js/external/**/*.js' , 'src/js/external/**/*.js.*' , 'src/js/external/**/*.min*']
  HTML:         [ 'src/**/*.html' ]
  JADE:         [ 'src/**/*.jade', '!src/**/_*.jade' ]
  LESS:         [ 'src/styling/**/*.less' ]
  TARGET:       [ 'build' ]

TYPE = 'dev'

notify = (event) ->
  util.log 'File #{event.path.split('/').splice(-1)} was #{event.type}, running tasks...'

onError = (err) ->
  try util.log err.toString()
  catch e
    util.log err
  @emit 'end'

getFolders = (dir) ->
  fs.readdirSync(dir).filter (file) ->
    fs.statSync(path.join(dir, file)).isDirectory()

gulp.task 'coffee', coffeeTask = (cb) ->
    gulp.src(SRC.COFFEE)
      .pipe($.plumber(errorHandler: onError))
      .pipe($.coffee(bare: true))
      .pipe($.concat('main.js'))
      .pipe($.if(TYPE == 'dist', $.uglify()))
      .pipe($.if(TYPE == 'dist', $.stripDebug()))
      .pipe(gulp.dest(SRC.TARGET + '/js'))
  # es.concat.apply null, getFolders('src/js/main').map (folder) ->

gulp.task 'less', lessTask = (cb) ->
  gulp.src(SRC.LESS)
    .pipe($.plumber({errorHandler: onError}))
    .pipe($.less())
    .pipe($.if(TYPE == 'dist', $.minifyCss()))
    .pipe($.autoprefixer('browsers': ['> 1%','ie >= 8']))
    .pipe(gulp.dest(SRC.TARGET + '/css'))

gulp.task 'jade', jadeTask = (cb) ->
  gulp.src(SRC.JADE)
    .pipe($.plumber({errorHandler: onError}))
    .pipe($.jade(pretty: "\t"))
    .pipe(gulp.dest(SRC.TARGET + '/'))

gulp.task 'assets', assetsTask = (cb) ->
  gulp.src(SRC.ASSETS)
    .pipe($.plumber({errorHandler: onError}))
    .pipe(gulp.dest(SRC.TARGET + '/assets'))

gulp.task 'externalJS', externalJSTask = (cb) ->
  gulp.src(SRC.EXTERNAL_JS)
    .pipe($.plumber({errorHandler: onError}))
    .pipe($.rename({dirname: ''}))
    # .pipe(concat('external.js'))
    .pipe(gulp.dest(SRC.TARGET + '/js/external'))

gulp.task 'browser-sync', browserSyncTask = (cb) ->
  files = [ SRC.TARGET + '/**' ]
  browserSync.init files,
    server:
      baseDir: SRC.TARGET
    notify: false
    open: false

gulp.task 'watch', (cb) ->
  $.watch SRC.ASSETS, assetsTask
  $.watch SRC.COFFEE, coffeeTask
  $.watch SRC.EXTERNAL_JS, externalJSTask
  $.watch SRC.JADE, assetsTask
  $.watch SRC.LESS, lessTask

# Clean
gulp.task 'clean', (cb) ->
  del SRC.TARGET + '/**', cb

# Default task
gulp.task 'default', ->
  runSequence 'clean', ['coffee', 'jade', 'less', 'externalJS', 'assets'], ['watch', 'browser-sync']

gulp.task 'dist', ->
  TYPE = 'dist'
  runSequence 'clean', ['coffee', 'jade', 'less', 'externalJS', 'assets'], ['watch', 'browser-sync']
