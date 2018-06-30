$(document).on('page:change', function(event) {
  $(document).ready(function() {
    $('.badge').popover({
      container: 'body',
      placement: 'bottom',
      trigger: 'hover'
    });
  });
});
