angular.module("app.constants", [])

.constant("API_URL", "https://api.topcoder.com")

.constant("AVATAR_URL", "https://www.topcoder.com")

.constant("SUBMISSION_URL", "https://studio.topcoder.com")

.constant("AUTH0_CLIENT_ID", "abc123")

.constant("AUTH0_DOMAIN", "topcoder.auth0.com")

.constant("AUTH0_TOKEN_NAME", "userJWTToken")

.constant("AUTH0_REFRESH_TOKEN_NAME", "userRefreshJWTToken")

;
(function() {
  'use strict';
  var dependencies;

  dependencies = ['ui.router', 'ngResource', 'app.constants', 'appirio-tech-ng-auth'];

  angular.module('example', dependencies);

}).call(this);

angular.module("example").run(["$templateCache", function($templateCache) {$templateCache.put("views/ng-auth.html","<button ng-click=\"vm.login()\" class=\"success\">login</button><hr/><button ng-click=\"vm.logout()\" class=\"danger\">logout</button><hr/><button ng-click=\"vm.refreshToken()\" class=\"warning\">refreshToken</button><hr/><button ng-click=\"vm.isLoggedIn()\" class=\"info\">isLoggedIn</button><hr/><button ng-click=\"vm.isAuthenticated()\" class=\"info\">isAuthenticated</button><hr/><label>callbacks:</label><p>{{ vm.message }}</p><hr/><label>token:</label><p>{{ vm.token }}</p><hr/><label>refresh token:</label><p>{{ vm.aRefreshToken }}</p>");}]);
(function() {
  'use strict';
  var config;

  config = function($stateProvider) {
    var key, results, state, states;
    states = {};
    states['ng-auth'] = {
      url: '/',
      title: 'ngAuth',
      controller: 'NgAuthController as vm',
      templateUrl: 'views/ng-auth.html'
    };
    results = [];
    for (key in states) {
      state = states[key];
      results.push($stateProvider.state(key, state));
    }
    return results;
  };

  config.$inject = ['$stateProvider'];

  angular.module('example').config(config).run();

}).call(this);

(function() {
  'use strict';
  var NgAuthController;

  NgAuthController = function(AuthService, TokenService) {
    var activate, getTokens, vm;
    vm = this;
    vm.message = '';
    vm.token = '';
    vm.aRefreshToken = '';
    getTokens = function() {
      vm.token = TokenService.getToken();
      return vm.aRefreshToken = TokenService.getRefreshToken();
    };
    vm.login = function() {
      var onSuccess, params;
      onSuccess = function() {
        vm.message = 'login done';
        return getTokens();
      };
      params = {
        username: 'happyTurtle',
        password: 'eatingAFlower',
        success: onSuccess
      };
      return AuthService.login(params);
    };
    vm.refreshToken = function() {
      var onSuccess;
      onSuccess = function() {
        vm.message = 'refreshToken done';
        return getTokens();
      };
      return AuthService.refreshToken(onSuccess);
    };
    vm.logout = function() {
      AuthService.logout();
      vm.message = 'logout done';
      return getTokens();
    };
    vm.isLoggedIn = function() {
      return vm.message = AuthService.isLoggedIn();
    };
    vm.isAuthenticated = function() {
      return vm.message = AuthService.isAuthenticated();
    };
    activate = function() {
      getTokens();
      return vm;
    };
    return activate();
  };

  NgAuthController.$inject = ['AuthService', 'TokenService'];

  angular.module('example').controller('NgAuthController', NgAuthController);

}).call(this);
