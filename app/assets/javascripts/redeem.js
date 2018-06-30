$(document).on('page:change', function(){
  alert_user();
});

var alert_user = function() {
  $(document).on('click', 'button.submit-redeem', function(event){
    event.stopPropagation();
    event.stopImmediatePropagation();
    var form = $(this).parent('form');
    var points = $(this).data().points;
      bootbox.confirm({
        title: 'Alert',
        message: "You have $ " + points + " in your account. <br> Are you sure you want to continue?",
        buttons: {
          confirm: {
            label: 'Continue',
            className: 'btn-success'
          },
          cancel: {
            label: 'Cancel',
            className: 'btn-danger'
          }
        },
        callback: function (result) {
          if (result) {
            $(form).submit();
          }
        }
      });
  });
};
