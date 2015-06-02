(function() {
  'use strict';
  var srv, transformResponse;

  transformResponse = function(response) {
    var parsed, ref;
    parsed = JSON.parse(response);
    return (parsed != null ? (ref = parsed.result) != null ? ref.content : void 0 : void 0) || [];
  };

  srv = function($resource, apiUrl) {
    var actions, params, url;
    url = apiUrl + 'authorizations/:id';
    params = {
      id: '@id'
    };
    actions = {
      update: {
        method: 'PUT',
        isArray: true,
        transformResponse: transformResponse
      }
    };
    return $resource(url, params, actions);
  };

  srv.$inject = ['$resource', 'apiUrl'];

  angular.module('appirio-tech-ng-auth').factory('AuthorizationsAPIService', srv);

}).call(this);
