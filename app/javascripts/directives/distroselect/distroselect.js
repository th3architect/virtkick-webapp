define(function(require) {
  var module = require('module');
  var angular = require('angular');

  require('angular-sanitize');

  require('ui-select');

  function controller($scope) {
    $scope.isoImages = $scope.$parent.isoImages;
    $scope.idToCode = $scope.$parent.idToCode;
  }

  function link(scope, element, attrs) {

  }

  angular.module(module.uri, ['ngSanitize', 'ui.select'])
  .directive('distroselect', function() {
    return {
      replace: true,
      transclude: true,
      restrict: 'E',
      scope: {
        machine: '='
      },
      controller: controller,
      template: require('jade!./distroselect')(),
      link: link
    };
  });
  return module.uri;
});