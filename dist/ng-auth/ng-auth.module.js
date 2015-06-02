(function() {
  'use strict';
  var config, dependencies, run;

  dependencies = ['angular-storage', 'angular-jwt', 'app.constants', 'auth0'];

  config = function($httpProvider, jwtInterceptorProvider, authProvider, auth0Domain, auth0ClientId) {
    var jwtInterceptor, logout;
    jwtInterceptor = function(TokenService) {
      return TokenService.getToken();
    };
    jwtInterceptor.$inject = ['TokenService'];
    jwtInterceptorProvider.tokenGetter = jwtInterceptor;
    $httpProvider.interceptors.push('jwtInterceptor');
    authProvider.init({
      domain: auth0Domain,
      clientID: auth0ClientId,
      loginState: 'login'
    });
    logout = function(TokenService) {
      return TokenService.deleteToken();
    };
    logout.$inject = ['TokenService'];
    return authProvider.on('logout', logout);
  };

  run = function($rootScope, $injector, $state, auth, TokenService, AuthService) {
    var checkAuth, checkRedirect;
    auth.hookEvents();
    checkRedirect = function() {
      var isProtected, notLoggedIn;
      isProtected = !toState.data || (toState.data && !toState.data.noAuthRequired);
      notLoggedIn = !AuthService.isAuthenticated();
      if (isProtected && notLoggedIn) {
        $rootScope.preAuthState = toState.name;
        event.preventDefault();
        return $state.go('login');
      }
    };
    return checkAuth = function(event, toState) {
      var isInvalidToken;
      isInvalidToken = TokenService.getToken() && !TokenService.tokenIsValid();
      if (isInvalidToken) {
        AuthService.refreshToken().then(function() {
          return checkRedirect();
        });
      } else {
        checkRedirect();
      }
      return $rootScope.$on('$stateChangeStart', checkAuth);
    };
  };

  angular.module('appirio-tech-ng-auth', dependencies).config(config).run(authRun);

}).call(this);
