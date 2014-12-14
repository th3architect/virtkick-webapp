define(function(require) {
  require('appcommon');
  var $ = require('jquery');
  //require('bootstrap');
  require('!domReady');
  require('twitter/bootstrap/rails/confirm');
  //require('./_console');
  require('ui-bootstrap');
  require('angular-sanitize');
  require('angular-messages');
  require('ui-select');

  var angular = require('angular');
  
  // ngSanitize is for ng-bind-html
  var app = angular.module('app',
    ['ui.bootstrap','ngSanitize','ngMessages', 'ui.select', require('./console')]
  );

  app.controller('AppCtrl', function($scope) {
    $scope.data = {
      menuCollapse: false
    };
  });

  app.controller('ShowMachineCtrl', function($scope, $rootScope, $http) {
    $scope.machine = JSON.parse($('#initialMachineData').html());

    $scope.idToCode = {};
    JSON.parse($("#isoData").html()).forEach(function(image) {
      $scope.idToCode[image.attributes.id] = image.attributes.code;
    });

    $scope.isoImages = JSON.parse($("#isoImagesData").html()).map(function(image) {
      return image.attributes;
    });

    $scope.data = {
      active: {
        power: true,
      }
    };

    var updateSelectedIso = function() {
      $scope.data.selectedIso = $scope.isoImages.filter(function(image) {
        return image.id === $scope.machine.iso_image_id
      })[0]
    };

    updateSelectedIso();

    $scope.changeIso = function(imageId) {
      $scope.data.mountingIso = true;
      $.post('/machines/' + $scope.machine.id + '/mount_iso', {
        machine: {
          iso_image_id: imageId
        }
      }).then(function(data) {
        handleProgress(data.progress_id, function() {
          $scope.data.mountingIso = false;
        }, function() {
          $scope.data.mountingIso = false;
        });
      }, function(error) {
        // TODO handle error
        $scope.data.mountingIso = false;
      });
    };

    $scope.console = {}; // will be bound by directive

    var baseUrl = '/machines/' + $scope.machine.id;

    $scope.toHumanValue = function(val) {
      val += " MB";
      return val;
    }




    var handleProgress = function(progressId, onSuccess, onError) {
        var id = setInterval(function() {
          return $.ajax('/progress/' + progressId).success(function(data) {
            if (!data.finished) {
              return;
            }
            clearInterval(id);

            data.error === null ? onSuccess() : onError(data.error);
          });
        }, 500);
      };

      $scope.$watch(function() {

        if($scope.machine.status.attributes.id === 'stopped') {
          $scope.canDo = {
            start: !$scope.requesting.starting, pause: false, resume: false, stop: false, restart: false, force_restart: false, force_stop: false
          };
        }
        else {
          $scope.canDo = {
            start: false,
            pause: $scope.machine.status.attributes.running,
            resume: !$scope.machine.status.attributes.running,
            stop: $scope.machine.status.attributes.running,
            restart: $scope.machine.status.attributes.running && !$scope.requesting.restart,
            force_restart:true,
            force_stop: true
          };
        }

      });

    $scope.doAction = function(name) {

      var actionUrl = baseUrl + '/' + name;

      $scope.requesting[name]= true;
      $.post(actionUrl).then(function(data) {
        handleProgress(data.progress_id, function() {
          $scope.requesting[name]= false;
          $scope.data.error = null;
        }, function(error) {
          $scope.requesting[name]= false;
          $scope.data.error = error;
        });
      });
    };

    $scope.requesting = {};
    $scope.canDo = {};

    var timeoutHandler;
    function updateState() {
      var skipIsoUpdate = !$scope.data.mountingIso;
      $http.get(baseUrl + '.json').then(function(response) {
        $scope.machine = response.data;

        // prevent live updates from changing this until the process ended
        if(!skipIsoUpdate && !$scope.data.mountingIso) {
          updateSelectedIso();
        }

        timeoutHandler = setTimeout(updateState, 1000);
      }, function() {
        $scope.machine.stateDisconnected = true;
        timeoutHandler = setTimeout(updateState, 5000);
      });
    }
    timeoutHandler = setTimeout(updateState, 1000);

    $scope.$on('$destroy', function() {
      clearTimeout(timeoutHandler);
    });
    

    $scope.$watch('data.active.console', function(val) {
      if($scope.console.connect)
        $scope.console.connect();
      $scope.$parent.data.menuCollapse = $scope.data.active.console;
    });
  });

  angular.element().ready(function() {
    angular.bootstrap(document, ['app']);
  });


  var handleProgress = function(progressId, onSuccess, onError) {
    var id = setInterval(function() {
      return $.ajax('/progress/' + progressId).success(function(data) {
        if (!data.finished) {
          return;
        }
        clearInterval(id);

        data.error === null ? onSuccess() : onError(data.error);
      });
    }, 500);
  };

  // ISO image change (Console & Settings Tabs)

  $('.iso_dropdown').change(function() {
    var form = $(this).closest('form');
    form.submit();
    var spinner = form.find('.fa-spinner');
    spinner.removeClass('hidden');
    form.on('ajax:success', function(e, data) {
      handleProgress(data.progress_id, function() {
        spinner.addClass('hidden');

        var tick = form.find('.fa-check');
        tick.removeClass('hidden');
        setTimeout(function() {
          tick.fadeOut('slow', function() {
            tick.addClass('hidden');
            tick.show();
          });
        }, 500);

      }, function(error) {
        spinner.addClass('hidden');
        form.find('fa-warning').removeClass('hidden');
      })
    })
  });


  // Storage Tab

  $('#page-storage .create-button').click(function() {
    $('#page-storage .create-button').fadeOut(200, function () {
      $('#page-storage .new').fadeIn(200);
    });
  });

  $('#page-storage .save-button').click(function() {
    $('#page-storage .new').fadeOut(200, function () {
      $('#page-storage .create-button').fadeIn(200);
    });
  });

  $('#new_disk').submit(function() {
    var form = $(this);
    var example = $('.example');
    var row = example.clone();
    row.removeClass('example hidden');
    row.find('.name .name').text(form.find('.name').text());
    row.find('.type').text(form.find('.type select :selected').text());
    row.find('.size').text(form.find('.size select :selected').text() + ' GB');
    example.closest('table').prepend(row);

    $.post(form.attr('action'), form.serializeArray()).success(function(data) {
      handleProgress(data.progress_id, function() {
        row.find('.name .fa-spinner').remove();
        var tick = row.find('.name .fa-check');
        tick.removeClass('hidden');
        setTimeout(function() {
          tick.fadeOut('slow');
        }, 500);
      }, function (error) {
        row.find('.name .fa-spinner').remove();
        row.find('.name .error').removeClass('hidden');
        row.find('.name .message').text(error);
      });
    });

    return false;
  });

  $('a.delete-disk').on('ajax:success', function(e, data) {
    var link = $(e.currentTarget);
    var row = link.closest('tr');
    row.find('.name .fa-spinner').removeClass('hidden');

    handleProgress(data.progress_id, function() {
      row.fadeOut('slow');
      setTimeout(function () {
        row.remove();
      }, 1000);
    }, function (error) {
      row.find('.name .fa-spinner').addClass('hidden');
      row.find('.name .error').removeClass('hidden');
      row.find('.name .message').text(error);
    });
  });

});

