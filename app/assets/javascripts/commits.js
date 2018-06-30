$(document).on('page:change', function(event) {
  $(document).ready(function() {
    $(document).on('click', '.reveal', function() {
      var $this = $(this);
      $this.fadeOut('fast', function() {
        $this.closest('td').find('.reward').fadeIn('slow').show();
        $this.replaceWith();
      });
    });
  });

  $(document).ready(function() {
    $('.reveal_all').on('click', function() {
      $('.reveal').fadeOut('slow').replaceWith();
      $('.reward').fadeIn('slow').show();
    });
  });

  $(document).ready(function() {
    $('.scores').tooltip({
      title: 'Not Yet Scored, Be Patient!',
      placement: 'left'
    });

    $('.rewards').tooltip({
      title: 'Not Yet Rewarded, Be Patient!',
      placement: 'left'
    });
  });
});
