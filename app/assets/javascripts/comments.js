
$(document).on("click", ".show-comments", function(e){
  e.stopPropagation();
  var $ele = $(this), commentsId, $comments;

  if($ele.hasClass("open")){
    commentsId = $ele.data("id");
    $comments = $("#comments_" + commentsId + ' .direct-chat-messages')
    $comments.html("");
  }else{
    $.get($ele.data('url'));
  }
  
  $ele.toggleClass("open");
});
