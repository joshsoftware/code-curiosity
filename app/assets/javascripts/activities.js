$(document).on('page:change', function(event) {

  $(".shorten_read").shorten({
    showChars: 100,
    moreText: 'show more',
    lessText: 'show less'
  });
  
});