module.exports = (karma) ->
  karma.set do
    basePath: "../"
    frameworks: ["mocha", "chai"]
    files:
      * "_public/js/vendor.js"
      * "_public/js/app.templates.js"
      * "_public/js/app.js"
      * "bower_components/angular-mocks/angular-mocks.js"
      * "test/unit/**/*.spec.ls"
    exclude: []
    reporters: ["progress"]
    port: 9876
    runnerPort: 9100
    colors: true
    logLevel: karma.LOG_INFO
    autoWatch: true
    browsers: <[PhantomJS]>
    captureTimeout: 60000
    plugins: <[karma-mocha karma-chai karma-live-preprocessor karma-phantomjs-launcher]>
    preprocessors:
      '**/*.ls': ['live']
    singleRun: false

module.exports.karma-deps = do
  'karma': '^0.12.23'
  'karma-live-preprocessor': '^0.2.2'
  'karma-mocha': '~0.1.0'
  'karma-chai': '^0.1.0'
  'karma-ng-scenario': '0.1.0'
  'karma-phantomjs-launcher': '~0.1.0'
  'mocha': '^1.21.4'
  'chai': '^1.9.0'
