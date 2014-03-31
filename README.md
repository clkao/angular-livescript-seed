angular-livescript-seed
=======================

Ultra-modern angular-livescript seed with:
* LiveScript
* gulp
* bower
* semantic-ui
* stylus
* angular-ui-router
* protractor

This resembles pretty much the [brunch](http://brunch.io) standard build process with gulp, with minor tweaks for angular:
* vendor javascript files from bower and vendor/ directory are concatenated into vendor.js
* js under app/ are concatenated into app.js
* partial templates written in jade are turned into angular module as 'app.templates' and concatenated into app.templates.js
* css files are concatenated into app.css

# Usage

Install required packages:

1.    `$ npm install`
2.    `$ npm run build`

Start server:

    $ npm run dev   # then open http://localhost:3333/

# License

The MIT license: http://clkao.mit-license.org/
