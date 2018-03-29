
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

  $(function() {
    $('#redeem').bootstrapToggle();
  })

  $(function() {
    $('#sponsorer').bootstrapToggle();
  })
  
  $('#redeem').change(function() {
    if($(this).is(':checked')){
      console.log(this.checked);
      $.ajax({
        type: 'get',
        url: '/admin/redeem_requests', 
        data: {'status': false}
      })
    }
    else{
      console.log($(this).is(':checked'));
      $.ajax({
        type: 'get',
        url: '/admin/redeem_requests',
        data: {'status': true}
      })
    }

  })

  $('#sponsorer').change(function() {
    if($(this).is(':checked')){
      console.log(this.checked);
      $.ajax({
        type: 'get',
        url: '/admin/redeem_requests', 
        data: {'is_sponsorer': false}
      })
    }
    else{
      console.log($(this).is(':checked'));
      $.ajax({
        type: 'get',
        url: '/admin/redeem_requests',
        data: {'is_sponsorer': true}
      })
    }

  })

  $("a.closeDropdown").on( "click", function() {
   $("#store").dropdown("toggle");
  })
});
