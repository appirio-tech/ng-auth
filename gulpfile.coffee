gulp          = require 'gulp'
$             = require('gulp-load-plugins')()
$.browserSync = require 'browser-sync'
$.karma       = require('karma').server

karmaConfig =
  configFile  : __dirname + '/karma.conf.coffee'
  coverage    : 'app/**/*.coffee'
  # Dont include coverage files
  coffeeFiles : [
    'tests/specs/**/*.coffee'
  ]
  files: [
    'bower_components/angular/angular.js'
    'bower_components/angular-mocks/angular-mocks.js'
    'bower_components/angular-resource/angular-resource.js'
    'bower_components/a0-angular-storage/dist/angular-storage.js'
    'bower_components/angular-jwt/dist/angular-jwt.js'
    'bower_components/auth0.js/build/auth0.js'
    'bower_components/auth0-angular/build/auth0-angular.js'
    'bower_components/angular-ui-router/release/angular-ui-router.js'
    'bower_components/auto-config-fake-server/dist/scripts/auto-config-fake-server.js'
    'tests/specs/helper.coffee'
    '.tmp/scripts/constants.js'
    '.tmp/scripts/json-fixtures.js'
    'app/scripts/**/*.module.coffee'
    'app/**/*.coffee'
    'tests/specs/**/*.coffee'
  ]

fixtureFiles = [
  'bower_components/appirio-tech-api-schemas/v3.json'
  'bower_components/appirio-tech-api-schemas/v2.json'
  'bower_components/appirio-tech-api-schemas/v3-authorizations.json'
]

configs =
  coffeeFiles     : 'app/**/*.coffee'
  jadeFiles       : 'app/**/*.jade'
  scssFiles       : 'app/**/*.scss'
  scssIncludePaths: require('appirio-work-styles').includePaths
  tempFolder      : '.tmp'
  appFolder       : 'app'
  distFolder      : 'dist'
  karma           : karmaConfig
  fixtureFiles    : fixtureFiles
  constants:
    apiUrl          : 'https://api.topcoder-dev.com/v3/' # slash is grandfathered in from river
    API_URL         : 'https://api.topcoder-dev.com/v3'
    API_URL_V2      : 'https://api.topcoder-dev.com/v2'
    AVATAR_URL      : 'http://www.topcoder.com'
    SUBMISSION_URL  : 'https://studio.topcoder.com'
    AUTH0_CLIENT_ID : 'abc123',
    AUTH0_DOMAIN    : 'topcoder-dev.auth0.com'
    AUTH0_TOKEN_NAME: 'userJWTToken'
  coverageReporter:
    type: 'lcov'
    dir: 'coverage'

tasks = [
  'coffee'
  'jade'
  'scss'
  'clean'
  'serve'
  'build'
  'test'
  'ng-constant'
  'coveralls'
  'fixtures'
]

for task in tasks
  module = require('./node_modules/appirio-gulp-tasks/tasks/' + task)
  module gulp, $, configs

gulp.task 'default', ['clean'], ->
  gulp.start 'build'

