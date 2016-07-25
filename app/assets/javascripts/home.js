$(document).ready(function() {
  var size = $('.carousel .item').size();
  $('.carousel .item').each(function(){

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
	  if (size > 3){
            $(this).siblings(':first').children(':first-child').clone().appendTo($(this));
	  }
    }
  });
});
