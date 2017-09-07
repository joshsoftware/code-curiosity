$(document).on('page:change', function(event) {

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
