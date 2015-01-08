define(function(require) {

  var module = require('module');
  var angular = require('angular');
  var $ = require('jquery');
  var RFB = require('novnc/rfb');

  function controller($scope) {
    $scope.ungrab = function() {
      $scope.rfb.get_keyboard().ungrab();
      $scope.rfb.get_mouse().ungrab(); 
      $scope.focused = false;
    }
    $scope.grab = function() {
     $scope.rfb.get_keyboard().grab(); 
     $scope.rfb.get_mouse().grab(); 
     $scope.focused = true;
    }
    $scope.sendCtrlAltDel = function() {
      $scope.rfb.sendCtrlAltDel();
    }
  }

  function link(scope, element, attrs) {

    var rfb;
    var hardResetRequested = false;
    var connectLoop = false;
    var $canvasWrapper = element;

    function updateConsole() {
      var width, height;
      if (!rfb) {
        width = 640;
        height = 480;
      } else {
        width = rfb.get_display().get_width();
        height = rfb.get_display().get_height();
      }

      // after connecting first noVNC frames are not real screens, so catch only
      // realistic sizes to avoid console flickering
      if (height <= 20) {
        return;
      }

      $canvasWrapper.width(width + "px");
      $canvasWrapper.height(height + "px");
      var margin = 70;
      var left = ($('#page-machine').width() - width - margin) / 2;
      left -= $('.side-menu-wrapper').outerWidth() / 2;
  
      $('.console-window').css("margin-left", left);

    }


    var connect = function() {
      if (!connectLoop) {
        return;
      }

      var host = window.location.hostname;
      var port = window.location.port;
      var password = attrs.password;
      var uuid = attrs.uuid;

      rfb.connect(host, port, password, window.location.pathname.substr(1) + "/vnc");
    };

    // http://stackoverflow.com/questions/16881478/how-to-call-a-method-defined-in-an-angularjs-directive
    if(scope.control) {
      scope.control.connect = function() {
        if(scope.state.vncState == 'normal')
          return;
        connectLoop = true;
        connect();
      };
    }

    scope.rfb = rfb = new RFB({
      'target': element.find('canvas')[0],
      'repeaterID': '',
      'encrypt': location.protocol === 'https:',
      'true_color': true,
      'local_cursor': true,
      'shared': true,
      'focused': false,
      'onUpdateState': function(rfb, state, oldstate, statusMsg) {
        scope.state.vncState = state;
        if(state === 'failed') {
          setTimeout(connect, 1000);
        }
        // force ungrab mouse if not focused
        if(!scope.focused) {
          rfb.get_keyboard().ungrab();
        }
        return;
      },
      'onFBUComplete': function (rfb, fbu) {
        updateConsole();
      },
      'view_only': false,
      'onPasswordRequired': function() {
        console.log('VNC: Password required');
      }
    });
    
    //$('.side-menu-wrapper').addClass('collapsed');

    $('#page-console .ctrlaltdel').click(function() {
      rfb.sendCtrlAltDel();
    });

    $('#page-console .hardreset').click(function() {
      hardResetRequested = true;
    });

    $(window).resize(function () {
      updateConsole();
    });

    updateConsole();


  }



  angular.module(module.uri, []).directive('console', function() {

    return {
      replace: true,
      restrict: 'E',
      scope: {
        focused: '=',
        state: '=',
        control: '='
      },
      controller: controller,
      templateUrl: '/templates/machine/console.html',
      link: link
    }
  });
  return module.uri;


  
});