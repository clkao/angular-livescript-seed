require! <[gulp gulp-util gulp-stylus gulp-livereload gulp-livescript streamqueue gulp-if gulp-plumber]>
gutil = gulp-util
require! <[nib]>
{protractor, webdriver_update} = require 'gulp-protractor'

dev = gutil.env._.0 is \dev
plumber = ->
  gulp-plumber error-handler: ->
    gutil.beep!
    gutil.log gutil.colors.red it.toString!
livereload-server = require('tiny-lr')!
livereload = -> gulp-livereload livereload-server

var http-server
production = true if gutil.env.env is \production
# replace your google analytics id here
google-analytics = 'UA-blah-blah' if gutil.env.env is \production

gulp.task 'httpServer' ->
  require! express
  app = express!
  app.use require('connect-livereload')!
  app.use '/' express.static "_public"
  app.all '/**' (req, res, next) ->
    res.send-file __dirname + '/_public/index.html'
  # use http-server here so we can close after protractor finishes
  http-server := require 'http' .create-server app
  port = 3333
  http-server.listen port, ->
    gutil.log "Running on " + gutil.colors.bold.inverse "http://localhost:#port"

gulp.task 'webdriver_update' webdriver_update

gulp.task 'protractor' <[webdriver_update httpServer]> ->
  gulp.src ["./test/e2e/app/*.ls"]
    .pipe protractor configFile: "./test/protractor.conf.ls"
    .on 'error' ->
      throw it

gulp.task 'test:e2e' <[protractor]> ->
  httpServer.close!

gulp.task 'protractor:sauce' <[webdriver_update build httpServer]> ->
  args =
    '--selenium-address'
    ''
    '--sauce-user'
    process.env.SAUCE_USERNAME
    '--sauce-key'
    process.env.SAUCE_ACCESS_KEY
    '--capabilities.build'
    process.env.TRAVIS_BUILD_NUMBER
  if process.env.TRAVIS_JOB_NUMBER
    #args['capabilities.tunnel-identifier'] = that
    args.push '--capabilities.tunnel-identifier'
    args.push that

  gulp.src ["./test/e2e/app/*.ls"]
    .pipe protractor do
      configFile: "./test/protractor.conf.ls"
      args: args
    .on 'error' ->
      throw it

gulp.task 'test:sauce' <[protractor:sauce]> ->
  httpServer.close!

gulp.task 'build' <[template bower assets js:vendor js:app css]>

gulp.task 'test:unit' <[build]> ->
  gulp.start 'test:karma' ->
    process.exit!

gulp.task 'test:karma' (done) ->
  require 'karma' .server.start {
    config-file: __dirname + '/test/karma.conf.ls',
    single-run: true
  }, done

gulp.task 'dev' <[template assets js:vendor js:app css]> (done) ->
  gulp.start 'httpServer'
  gulp.watch ['app/**/*.jade'] <[template]>
  gulp.watch ['app/**/*.ls', 'app/**/*.jsenv'] <[js:app]>
  gulp.watch 'app/assets/**' <[assets]>
  gulp.watch 'app/**/*.styl' <[css]>
  require 'karma' .server.start {
    config-file: __dirname + '/test/karma.conf.ls',
  }, ->
    done!
    process.exit!


require! <[gulp-angular-templatecache gulp-jade]>
gulp.task 'template' <[index]> ->
  gulp.src ['app/partials/**/*.jade']
    .pipe gulp-if dev, plumber!
    .pipe gulp-jade!
    .pipe gulp-angular-templatecache 'app.templates.js' do
      base: process.cwd()
      filename: 'app.templates.js'
      module: 'app.templates'
      standalone: true
    .pipe gulp.dest '_public/js'
    .pipe gulp-if dev, livereload!

gulp.task 'index' ->
  pretty = 'yes' if gutil.env.env isnt \production

  gulp.src ['app/*.jade']
    .pipe gulp-jade do
      pretty: pretty
      locals:
        googleAnalytics: google-analytics
    .pipe gulp.dest '_public'
    .pipe gulp-if dev, livereload!

require! <[gulp-bower main-bower-files gulp-filter gulp-uglify gulp-csso]>
require! <[gulp-concat gulp-json-editor gulp-commonjs gulp-insert]>

gulp.task 'bower' ->
  gulp-bower!

gulp.task 'js:app' ->
  env = gulp.src 'app/**/*.jsenv'
    .pipe gulp-json-editor (json) ->
      for key of json when process.env[key]?
        json[key] = that
      json
    .pipe gulp-insert.prepend 'module.exports = '
    .pipe gulp-commonjs!

  app = gulp.src 'app/**/*.ls'
    .pipe gulp-if dev, plumber!
    .pipe gulp-livescript({+bare}).on 'error', gutil.log

  s = streamqueue { +objectMode }
    .done env, app
    .pipe gulp-concat 'app.js'
    .pipe gulp-if production, gulp-uglify!
    .pipe gulp.dest '_public/js'
    .pipe gulp-if dev, livereload!

gulp.task 'js:vendor' <[bower]> ->
  bower = gulp.src main-bower-files!
    .pipe gulp-filter -> it.path is /\.js$/

  s = streamqueue { +objectMode }
    .done bower, gulp.src 'vendor/scripts/*.js'
    .pipe gulp-concat 'vendor.js'
    .pipe gulp-if production, gulp-uglify!
    .pipe gulp.dest '_public/js'
    .pipe gulp-if dev, livereload!

gulp.task 'css' <[bower]> ->
  bower = gulp.src main-bower-files!
    .pipe gulp-filter -> it.path is /\.css$/

  styl = gulp.src './app/styles/**/*.styl'
    .pipe gulp-filter -> it.path isnt /\/_[^/]+\.styl$/
    .pipe gulp-stylus use: [nib!]

  s = streamqueue { +objectMode }
    .done bower, styl, gulp.src 'app/styles/**/*.css'
    .pipe gulp-concat 'app.css'
    .pipe gulp-if production, gulp-csso!
    .pipe gulp.dest './_public/css'
    .pipe gulp-if dev, livereload!

gulp.task 'assets' ->
  gulp.src 'app/assets/**'
    .pipe gulp.dest '_public'

export gulp-deps = do
  "gulp": '^3.8.0'
  "gulp-util": '^3.0.1'
  "gulp-exec": '^2.1.0'
  "gulp-protractor": '^0.0.11'
  "gulp-livescript": '^1.0.3'
  "gulp-stylus": '^1.3.0'
  "gulp-concat": '^2.4.0'
  "gulp-jade": '^0.7.0'
  "gulp-angular-templatecache": '^1.1.0'
  "gulp-bower": '~0.0.2'
  "main-bower-files": '^1.0.1'
  "gulp-uglify": '^1.0.1'
  "gulp-csso": '~0.2.6'
  "gulp-filter": '^1.0.1'
  "gulp-mocha": '^1.0.0'
  "gulp-livereload": '^2.1.1'
  "gulp-json-editor": "^2.0.2"
  "gulp-commonjs": "^0.1.0"
  "gulp-insert": "^0.4.0"
  "gulp-if": '^1.2.4'
  "gulp-plumber": "^0.6.5"
  "streamqueue": '^0.1.1'
  "connect-livereload": '^0.4.0'
  "tiny-lr": '^0.1.1'
  "express": '^4.8.8'
  "nib": '^1.0.3'
