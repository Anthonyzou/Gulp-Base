'use strict'

autoprefixer =    require('gulp-autoprefixer')
browserSync =     require('browser-sync')
coffee =          require('gulp-coffee')
concat =          require('gulp-concat')
del =             require('del')
es =              require('event-stream')
fs =              require('fs')
gulp =            require('gulp')
gulpif =          require('gulp-if')
jade =            require('gulp-jade')
less =            require('gulp-less')
minifyCSS =       require('gulp-minify-css')
minifyHTML =      require('gulp-minify-html')
path =            require('path')
plumber =         require('gulp-plumber')
rename =          require('gulp-rename')
runSequence =     require('run-sequence').use(gulp)
stripDebug =      require('gulp-strip-debug')
uglify =          require('gulp-uglify')
util =            require('gulp-util')
watch =           require('gulp-watch')

SRC = 
  ASSETS:       [ 'src/assets/**/*' ]
  COFFEE:       [ 'src/js/main/**/*.coffee' ]
  EXTERNAL_JS:  [ 'src/js/external/**/*.js' , 'src/js/external/**/*.js.*' , 'src/js/external/**/*.min*']
  HTML:         [ 'src/**/*.html' ]
  JADE:         [ 'src/**/*.jade', '!src/**/_*.jade' ]
  LESS:         [ 'src/styling/**/*.less' ]
  TARGET:       [ 'build' ]

TYPE = process.env.ENVIRONMENT
util.log TYPE

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
      .pipe(plumber(errorHandler: onError))
      .pipe(coffee(bare: true))
      .pipe(concat('main.js'))
      .pipe(gulpif(TYPE == 'dist', stripDebug()))
      .pipe(gulp.dest(SRC.TARGET + '/js'))
  # es.concat.apply null, getFolders('src/js/main').map (folder) ->

gulp.task 'less', lessTask = (cb) ->
  gulp.src(SRC.LESS)
    .pipe(plumber({errorHandler: onError}))
    .pipe(less())
    .pipe(gulpif(TYPE == 'dist', minifyCSS()))
    .pipe(autoprefixer('browsers': ['> 1%','ie >= 8']))
    .pipe(gulp.dest(SRC.TARGET + '/css'))
  
gulp.task 'jade', jadeTask = (cb) ->
  gulp.src(SRC.JADE)
    .pipe(plumber({errorHandler: onError}))
    .pipe(jade(pretty: "\t"))
    .pipe(gulp.dest(SRC.TARGET + '/'))

gulp.task 'assets', assetsTask = (cb) ->
  gulp.src(SRC.ASSETS)
    .pipe(plumber({errorHandler: onError}))
    .pipe(gulp.dest(SRC.TARGET + '/assets'))

gulp.task 'externalJS', externalJSTask = (cb) ->
  gulp.src(SRC.EXTERNAL_JS)
    .pipe(plumber({errorHandler: onError}))
    .pipe(rename({dirname: ''}))
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
  watch SRC.ASSETS, lessTask
  watch SRC.COFFEE, coffeeTask
  watch SRC.EXTERNAL_JS, jadeTask
  watch SRC.JADE, assetsTask
  watch SRC.LESS, externalJSTask

# Clean
gulp.task 'clean', (cb) ->
  del SRC.TARGET + '/**', cb

# Default task
gulp.task 'default', ->
  runSequence 'clean', ['coffee', 'jade', 'less', 'externalJS', 'assets'], ['watch', 'browser-sync']
