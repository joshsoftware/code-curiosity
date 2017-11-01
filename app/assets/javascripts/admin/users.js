$(document).on('page:change', function(event) {

  $(function() {
    $('#blocked').bootstrapToggle();
  })

  $('#blocked').change(function() {
    $('#status').val(!this.checked);
    $('#q').val('');
    $.ajax({
      type: 'get',
      url: '/admin/users',
      data: { 'blocked': !(this.checked) }
    });
  });

  $(document).on('change', '.block', function(){
    id = this.id;
    $(".block#"+id).prop("disabled", true);
    $.ajax({
      type: 'patch',
      url: '/admin/users/'+id+'/block_user',
      data: { 'blocked': this.checked, 'id': id }
    })
  })
});
