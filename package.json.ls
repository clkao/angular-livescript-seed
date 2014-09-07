#!/usr/bin/env lsc -cj
author: 'Chia-liang Kao'
name: 'angular-livescript-seed'
description: 'ultra-modern angular seed with livescript'
version: '0.2.0'
homepage: 'https://github.com/clkao/angular-livescript-seed'
repository:
  type: 'git'
  url: 'https://github.com/clkao/angular-livescript-seed'
engines:
  node: '0.10.x'
  npm: '1.3.x'
scripts:
  republish: 'lsc -cj package.json.ls && lsc -cj bower.json.ls'
  build: 'gulp --require LiveScript build'
  dev: 'gulp --require LiveScript dev'
  test: 'gulp --require LiveScript test:unit'
  protractor: 'gulp --require LiveScript test:e2e'
dependencies: {}
devDependencies: require \./gulpfile.ls .gulp-deps <<<
  require \./test/karma.conf.ls .karma-deps <<< do
    express: '3.4.x'
    LiveScript: '1.2.x'
    'bower': '1.3.x'
    'protractor': '~0.18.1'
    "streamqueue": '~0.0.5'
    "connect-livereload": '~0.3.2'
    "tiny-lr": '~0.0.5'
