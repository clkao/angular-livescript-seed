require! <[tiny-lr]>
require! <[gulp gulp-util gulp-stylus gulp-karma gulp-livereload gulp-livescript streamqueue gulp-if]>
gutil = gulp-util
{protractor, webdriver_update} = require 'gulp-protractor'

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
    res.sendfile __dirname + '/_public/index.html'
  # use http-server here so we can close after protractor finishes
  http-server := require 'http' .create-server app
  port = 3333
  http-server.listen port, ->
    console.log "Running on http://localhost:#port"

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
  gulp.start 'test:karma'

gulp.task 'test:karma' ->
  gulp.src [
    * "_public/js/vendor.js"
    * "_public/js/app.templates.js"
    * "_public/js/app.js"
    * "bower_components/angular-mocks/angular-mocks.js"
    * "test/unit/**/*.spec.ls"
  ]
  .pipe gulp-karma do
    config-file: 'test/karma.conf.ls'
    action: 'run'
    browsers: <[PhantomJS]>
  .on 'error' ->
    console.log it
    throw it

gulp.task 'dev' <[httpServer template assets js:vendor js:app css]> ->
  LIVERELOADPORT = 35729
  livereload-server.listen LIVERELOADPORT, ->
    return gutil.log it if it
  gulp.watch ['app/**/*.jade'] <[template]>
  gulp.watch ['app/**/*.ls', 'app/**/*.jsenv'] <[js:app]>
  gulp.watch 'app/assets/**' <[assets]>
  gulp.watch 'app/**/*.styl' <[css]>

require! <[gulp-angular-templatecache gulp-jade]>
gulp.task 'template' <[index]> ->
  gulp.src ['app/partials/**/*.jade']
    .pipe gulp-jade!
    .pipe gulp-angular-templatecache 'app.templates.js' do
      base: process.cwd()
      filename: 'app.templates.js'
      module: 'app.templates'
      standalone: true
    .pipe gulp.dest '_public/js'
    .pipe livereload!

gulp.task 'index' ->
  pretty = 'yes' if gutil.env.env isnt \production

  gulp.src ['app/*.jade']
    .pipe gulp-jade do
      pretty: pretty
      locals:
        googleAnalytics: google-analytics
    .pipe gulp.dest '_public'
    .pipe livereload!

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
    .pipe gulp-livescript({+bare}).on 'error', gutil.log

  s = streamqueue { +objectMode }
    .done env, app
    .pipe gulp-concat 'app.js'
    .pipe gulp-if production, gulp-uglify!
    .pipe gulp.dest '_public/js'

gulp.task 'js:vendor' <[bower]> ->
  bower = gulp.src main-bower-files!
    .pipe gulp-filter -> it.path is /\.js$/

  s = streamqueue { +objectMode }
    .done bower, gulp.src 'vendor/scripts/*.js'
    .pipe gulp-concat 'vendor.js'
    .pipe gulp-if production, gulp-uglify!
    .pipe gulp.dest '_public/js'
    .pipe livereload!

gulp.task 'css' <[bower]> ->
  bower = gulp.src main-bower-files!
    .pipe gulp-filter -> it.path is /\.css$/

  styl = gulp.src './app/styles/**/*.styl'
    .pipe gulp-filter -> it.path isnt /\/_[^/]+\.styl$/
    .pipe gulp-stylus use: <[nib]>

  s = streamqueue { +objectMode }
    .done bower, styl, gulp.src 'app/styles/**/*.css'
    .pipe gulp-concat 'app.css'
    .pipe gulp-if production, gulp-csso!
    .pipe gulp.dest './_public/css'
    .pipe livereload!

gulp.task 'assets' ->
  gulp.src 'app/assets/**'
    .pipe gulp.dest '_public'

export gulp-deps = do
  "gulp": '~3.8.0'
  "gulp-util": '~2.2.13'
  "gulp-exec": '~1.0.4'
  "gulp-protractor": '^0.0.7'
  "gulp-livescript": '~0.1.1'
  "gulp-stylus": '~0.0.12'
  "gulp-concat": '~2.1.7'
  "gulp-jade": '~0.4.1'
  "gulp-angular-templatecache": '^1.1.0'
  "gulp-bower": '~0.0.2'
  "main-bower-files": '^1.0.1'
  "gulp-uglify": '~0.2.1'
  "gulp-csso": '~0.2.6'
  "gulp-filter": '~0.2.1'
  "gulp-mocha": '~0.4.1'
  "gulp-karma": '^0.0.4'
  "gulp-livereload": '~1.1.1'
  "gulp-json-editor": "^2.0.2"
  "gulp-commonjs": "^0.1.0"
  "gulp-insert": "^0.2.0"
  "gulp-if": '~0.0.5'
