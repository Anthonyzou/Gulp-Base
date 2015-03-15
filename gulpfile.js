var autoprefixer = require('gulp-autoprefixer'),
  browserSync = require('browser-sync'),
  concat = require('gulp-concat'),
  data = require('gulp-data');
  del = require('del')
  gulp = require('gulp'),
  gulpif = require('gulp-if'),
  jade = require('gulp-jade'),
  less = require('gulp-less'),
  minifyCSS = require('gulp-minify-css'),
  rename = require('gulp-rename'),
  stripDebug = require('gulp-strip-debug'),
  to5 = require('gulp-6to5'),
  uglify = require('gulp-uglify')
  util = require('gulp-util'),
  watch = require('gulp-watch'),
  plumber = require('gulp-plumber');

var SRC = {
  ASSETS:       ['src/assets/**'],
  ECMA6 :       ['src/**/*.js', '!src/js/external/**'],
  EXTERNAL_JS : ['src/js/external/**/*.min.js', 'src/js/external/**/*.js.*'],
  HTML :        ['src/**/*.html'],
  JADE :        ['src/**/*.jade', '!src/**/_*.jade'],
  LESS :        ['src/styling/**/*.less'],
  TARGET :      ['build']
};

gulp.task('less', 
  function(cb) {
    return gulp.src( SRC.LESS )
      .pipe( watch( SRC.LESS ) )
      .pipe( plumber())
      .pipe( less() )
      .pipe( gulpif(process.env.ENVIRONMENT === 'dist', minifyCSS()) )
      .pipe( autoprefixer({"browsers": ["> 1%", "ie >= 8"]}) )
      .pipe( gulp.dest(SRC.TARGET + '/css') );
  }
);

gulp.task('js',
  function (cb) {
    return gulp.src( SRC.ECMA6 )
      .pipe( watch( SRC.ECMA6 ) )
      .pipe( plumber() )
      .pipe( to5() )
      .pipe( concat('all.js') )
      .pipe( gulpif(process.env.ENVIRONMENT === 'dist', uglify()) )
      .pipe( gulpif(process.env.ENVIRONMENT === 'dist', stripDebug()) )
      .pipe( gulp.dest( SRC.TARGET + '/js')) ;
  }
);

gulp.task('jade' ,
  function(cb){
    return gulp.src( SRC.JADE )
      .pipe( watch( SRC.JADE ) )
      .pipe( plumber() )
      .pipe( jade( {
        pretty: '\t'
      }))
      .pipe(  gulp.dest( SRC.TARGET + '/') )
  }
);

gulp.task('assets',
  function (cb){
    return gulp.src( SRC.ASSETS )
      .pipe( watch( SRC.ASSETS ) )
      .pipe( gulp.dest( SRC.TARGET + '/assets' ) )
  }
);

gulp.task('externalJS',
  function (cb){
    return gulp.src( SRC.EXTERNAL_JS )
      .pipe( watch( SRC.EXTERNAL_JS ) )
      .pipe( gulp.dest( SRC.TARGET +'/js/external' ) )
  }
);

function notify ( event ) {
  console.log('\nFile ' + event.path + ' was ' + event.type + ', running tasks...\n')
}

gulp.task('browser-sync', function(cb) {
   var files = [
      SRC.TARGET + '/**'
   ];

   browserSync.init(files, {
    server: {
        baseDir: SRC.TARGET
    },
    notify: false
  });
});

// Clean
gulp.task('clean', function(cb) { del( SRC.TARGET + '/**' , cb)});
 
// Default task
gulp.task('default', ['clean'], function() {
    gulp.start('js', 'jade', 'less', 
                'externalJS', 'assets', 'browser-sync');
});


