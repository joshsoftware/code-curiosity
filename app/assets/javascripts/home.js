$(document).ready(function() {
  var size = Math.round($('.carousel .item').size()/3);
  var index = 0;
  $('.carousel .item').each(function(){
    index = index + 1;

    var next = $(this).next();
    if (!next.length) {
      next = $(this).siblings(':first');
    }
    if (!next.children(':first-child').attr('class').includes('glyphicon')) {
      next.children(':first-child').clone().appendTo($(this));
    } else {
      next = $('.carousel .item').first();
      next.children(':first-child').clone().appendTo($(this));
    }
  
    if (next.next().length > 0) {
        if (!next.next().children(':first-child').attr('class').includes('glyphicon')) {
          next.next().children(':first-child').clone().appendTo($(this));
	} else {
	  next = $('.carousel .item').first();
	  next.next().children(':first-child').clone().appendTo($(this));
	} 
    } 
    else {
          $(this).siblings(':first').children(':first-child').clone().appendTo($(this));
    }
  });
});
