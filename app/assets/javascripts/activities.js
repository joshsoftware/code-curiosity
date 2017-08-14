$(document).on('page:change', function(event) {
  initialize_shorten();
});

var initialize_shorten = function(){
  $(".shorten_read").shorten({
    showChars: 100,
    moreText: 'show more',
    lessText: 'show less'
  });
}