"use strict";

var autoprefixer = require('gulp-autoprefixer'),
  browserSync = require('browser-sync'),
  concat = require('gulp-continuous-concat'),
  data = require('gulp-data'),
  del = require('del'),
  gulp = require('gulp'),
  gulpif = require('gulp-if'),
  jade = require('gulp-jade'),
  less = require('gulp-less'),
  minifyCSS = require('gulp-minify-css'),
  stripDebug = require('gulp-strip-debug'),
  to5 = require('gulp-6to5'),
  uglify = require('gulp-uglify'),
  util = require('gulp-util'),
  watch = require('gulp-watch'),
  plumber = require('gulp-plumber');

var SRC = {
  ASSETS:       ['src/assets/**/*'],
  JS :          ['src/js/*.js'],
  EXTERNAL_JS : ['src/js/external/**/*.min.js'],
  HTML :        ['src/**/*.html'],
  JADE :        ['src/**/*.jade', '!src/**/_*.jade'],
  LESS :        ['src/styling/**/*.less'],
  TARGET :      ['build']
};

console.log(process.env.ENVIRONMENT);

gulp.task('less', 
  function(cb) {
    return gulp.src( SRC.LESS )
      .pipe( plumber() )
      .pipe( watch( SRC.LESS ) )
      .pipe( less() )
      .pipe( gulpif(process.env.ENVIRONMENT === 'dist', minifyCSS()) )
      .pipe( autoprefixer({"browsers": ["> 1%", "ie >= 8"]}) )
      .pipe( gulp.dest(SRC.TARGET + '/css') );
  }
);

gulp.task('js',
  function (cb) {
    return gulp.src( SRC.JS )
      .pipe( plumber() )
      .pipe( watch( SRC.JS ) )
      .pipe( to5() )
      .pipe( concat('main.js') )
      .pipe( gulpif(process.env.ENVIRONMENT === 'dist', uglify()) )
      .pipe( gulpif(process.env.ENVIRONMENT === 'dist', stripDebug()) )
      .pipe( gulp.dest( SRC.TARGET + '/js' )) ;
  }
);

gulp.task('jade' ,
  function(cb){
    return gulp.src( SRC.JADE )
      .pipe( plumber() )
      .pipe( watch( SRC.JADE ) )
      .pipe( jade( {
        pretty: '\t'
      }))
      .pipe( gulp.dest( SRC.TARGET + '/') );
  }
);

gulp.task('assets',
  function (cb){
    return gulp.src( SRC.ASSETS )
      .pipe( plumber() )
      .pipe( watch( SRC.ASSETS ) )
      .pipe( gulp.dest( SRC.TARGET + '/assets' ) );
  }
);

gulp.task('externalJS',
  function (cb){
    return gulp.src( SRC.EXTERNAL_JS )
      .pipe( plumber() )
      .pipe( watch( SRC.EXTERNAL_JS ) )
      .pipe( concat('external.js') )
      .pipe( gulp.dest( SRC.TARGET +'/js/external' ) );
  }
);

gulp.task('browser-sync', function(cb) {
   var files = [
      SRC.TARGET + '/**',
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
    gulp.start('js', 'jade', 'less', 'externalJS', 'assets', 'browser-sync');
});


