# ng-auth
[![Build Status](https://travis-ci.org/appirio-tech/ng-auth.svg)](https://travis-ci.org/appirio-tech/ng-auth)
[![Coverage Status](https://coveralls.io/repos/appirio-tech/ng-auth/badge.svg?branch=master&t=HjoYus)](https://coveralls.io/r/appirio-tech/ng-auth?branch=master)

## Install
```
bower install appirio-tech-ng-auth=git@github.com:appirio-tech/ng-auth --save
```

## Usage
### Include source
```html
<script src="/bower_components/appirio-tech-ng-auth/dist/main.js" type="text/javascript"></script>
```

### Add dependency
```coffeescript
'use strict'

dependencies = [
  'appirio-tech-ng-auth'
]

angular.module 'app', dependencies
```

### Login via a controller
``` coffeescript
controller = -> ($scope, AuthService)
  onSuccess = ->
    console.log 'log in successful'

  onError = ->
    console.log 'log in failed'
 
  $scope.login = ->
    loginOptions =
      username: $scope.username
      password: $scope.password
      error: onError
      success: onSuccess

    AuthService.login loginOptions
```