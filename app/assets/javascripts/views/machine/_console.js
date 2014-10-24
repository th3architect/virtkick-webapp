define(function(require) {
  var $ = require('jquery');
  var RFB = require('novnc/rfb');
  require('!domReady');
  
  var rfb;
  var hardResetRequested = false;
  var connectLoop = false;
  var $canvasWrapper = $('#page-console').find('.canvas-wrapper');

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

  $('.console').click(function() {
    var connect = function() {
      if (!connectLoop) {
        return;
      }

      var $canvas = $('#page-console').find('canvas');
      var host = window.location.hostname;
      var port = window.location.port;
      var password = $canvas.attr('data-password');
      var uuid = $canvas.attr('data-uuid');
      document.cookie = 'token=1-' + uuid + '; path=/';
      rfb.connect(host, port, password, window.location.pathname.substr(1) + "/vnc");
    };

    rfb = new RFB({
      'target': $('canvas')[0],
      'repeaterID': '',
      'encrypt': location.protocol === 'https:',
      'true_color': true,
      'local_cursor': true,
      'shared': true,
      'onUpdateState': function(rfb, state, oldstate, statusMsg) {
        if (state === 'normal') {
          $('#page-console .browser-info').hide();
          $('#page-console .status').addClass('hidden');
          hardResetRequested = false;
        } else if (state === 'failed') {
          if (hardResetRequested) {
            $('#page-console .browser-info').hide();
            $('#page-console .status').removeClass('hidden');
          } else {
            $('#page-console .browser-info').show();
            $('#page-console .status').addClass('hidden');
          }
          setTimeout(connect, 1000);
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

    $('.side-menu-wrapper').addClass('collapsed');

    connectLoop = true;
    connect();
  });

  $('#page-console .ctrlaltdel').click(function() {
    rfb.sendCtrlAltDel();
  });

  $('#page-console .hardreset').click(function() {
    hardResetRequested = true;
  });

  $('.nav a:not(.console)').click(function() {
    if (rfb) {
      rfb.disconnect();
    }
    connectLoop = false;
  });

  $('#page-machine .nav li').click(function (e) {
    if ($(e.currentTarget).find('.console').length == 0) {
      $('.side-menu-wrapper').removeClass('collapsed');
      $('.side-menu').removeClass('expanded');
    }
  });

  $('.side-menu-wrapper .dropdown').click(function () {
    $('.side-menu').toggleClass('expanded');
  });

  $(window).resize(function () {
    updateConsole();
  });

  updateConsole();
});