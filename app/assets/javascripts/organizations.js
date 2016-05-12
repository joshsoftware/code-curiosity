$(document).on('page:change', function(event) {
  $('#repo-widget-modal').on('show.bs.modal', function (event) {
    var button = $(event.relatedTarget);
    var modal = $(this);
    var code = '<iframe src="' + button.data('url') + '" height="380" width="340" frameborder="0"></iframe>';

    modal.find('.modal-title').text('Widget: ' + button.data('name'));
    modal.find('.modal-body .code').text(code);
  })
});
