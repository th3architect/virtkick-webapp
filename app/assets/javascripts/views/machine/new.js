define(function(require) {
  require('appcommon');
  var $ = require('jquery');
  
  var angular = require('angular');
  require('angular-messages'); // for ngMessages
  require('ui-bootstrap');

  var app = angular.module('app', ['ui.botstrap', 'ngMessages']);

  require('csrfSetup')(app);


  // directive for checking validity of the form
  // this will be wrapped in something nicer in the future :)
  app.directive('machine', function($q, $http) {
    return {
      require: 'ngModel',
      link: function(scope, elm, attrs, ctrl) {
        ctrl.$asyncValidators.machine = function(modelValue, viewValue) {
          return $q(function(resolve, reject) {
            if(typeof modelValue == 'undefined') {
              return reject();
            }
            $http.post('/machines',  {machine: {
              hostname: modelValue
            }}).success(function(arg) {
              resolve();
            }).error(function(arg) {
              // cache set errors
              ctrl.errors = ctrl.errors || {};
              Object.keys(ctrl.errors).forEach(function(error) {
                ctrl.$setValidity(error, true);
                delete ctrl.errors[error];
              });
              if(arg.errors.hostname) {

                arg.errors.hostname.forEach(function(error) {
                  ctrl.errors[error] = true;
                  ctrl.$setValidity(error, false);
                });


                return reject(arg.errors.hostname);
              }
              resolve();
            });
          });
        };
      }
    };
  });

  app.controller('NewMachineCtrl', function($scope) {
    $scope.data = {};

  });

  angular.element().ready(function() {
    angular.bootstrap(document, ['app']);
  });
});
