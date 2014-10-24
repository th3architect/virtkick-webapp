define(function(require) {
  require('appcommon');

  var $ = require('jquery');
  require('!domReady');

  var $creating = $('.creating');
  if ($creating.length > 0) {
    var url = $creating.attr('data-url');
    setInterval(function() {
      $.ajax(url).success(function(data) {
        if (!data.finished) {
          return;
        }

        if (data.error_message) {
          window.location.reload(false);
        } else {
          window.location.pathname = '/machines/' + data.given_meta_machine_id;
        }
      });
    }, 500);
  }

});