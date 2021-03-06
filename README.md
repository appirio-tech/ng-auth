# ng-auth
[![GitHub version](https://badge.fury.io/gh/appirio-tech%2Fng-auth.svg)](http://badge.fury.io/gh/appirio-tech%2Fng-auth)
[![Build Status](https://travis-ci.org/appirio-tech/ng-auth.svg)](https://travis-ci.org/appirio-tech/ng-auth)
[![Coverage Status](https://coveralls.io/repos/appirio-tech/ng-auth/badge.svg?branch=master&t=HjoYus)](https://coveralls.io/r/appirio-tech/ng-auth?branch=master)
[![Dependency Status](https://www.versioneye.com/user/projects/55d61cdb3b97d4001400029e/badge.svg?style=flat)](https://www.versioneye.com/user/projects/55d61cdb3b97d4001400029e)

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

### Check if user is logged in
```
isLoggedIn = AuthService.isLoggedIn
```

### Get current user
``` coffeescript

controller = -> ($scope, UserV3Service)
  vm = this
  scope.$watch UserV3Service.getCurrentUser, ->
    user = UserV3Service.getCurrentUser()
    vm.user = user if user
```
