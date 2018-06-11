
$(document).on('page:change', function(event) {
  $('#coupon-code-modal').on('show.bs.modal', function (event) {
    var button = $(event.relatedTarget);
    var modal = $(this);

    modal.find('form').attr('action', button.data('url'));
    modal.find('#redeem_request_coupon_code').val(button.data('code'));
    modal.find('#redeem_request_comment').val(button.data('comment'));
    modal.find('#redeem_request_points').val(button.data('points'));
    modal.find('#redeem_request_status').val(button.data('status') + '');
  })

  $('form#filter').on('change', function() {
    $(this).submit()
  });
});
