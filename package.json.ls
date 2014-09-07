#!/usr/bin/env lsc -cj
_: 'Do not edit, generated from package.json.ls'
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
    'LiveScript': '1.2.0'
    'bower': '^1.3.9'
    'protractor': '^1.2.0'
