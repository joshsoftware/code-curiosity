$(document).on('page:change', function(event) {

  $(function() {
    $('#repo').bootstrapToggle();
  })

  $('#repo').change(function() {
    query = $("#q").val();
    $.ajax({
      type: 'get',
      url: '/admin/repositories',
      data: { 'ignored': !(this.checked), query: query }
    })
  })

  $(document).on('change', '.secondary', function(){
    id = this.id;
    $(".secondary#"+id).prop('disabled', true);
    $.ajax({
      type: 'patch',
      url: "/admin/repositories/"+id+"/update_ignore_field",
      data: {'ignore_value': this.checked}
    })
  })
});

