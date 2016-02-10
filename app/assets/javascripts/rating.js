function showRatingControl(){
  $('.rating-control select').barrating('show', {
    theme: 'bars-pill',
    showValues: true,
    showSelectedRating: false,
    onSelect: function(value, text, event) {
      if (typeof(event) !== 'undefined') {
        var li = $(event.target).closest('li');
        var url = li.data('url')  
        $.post(url, { rating: value })
      }
    }
  });
}
