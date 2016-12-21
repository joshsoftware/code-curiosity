$(document).on('page:change', function(event) {

  $(function() {
    $('#file').bootstrapToggle();
  })

  $('#file').change(function() {
    query = $('#q').val();    
    $.ajax({
        type: 'get',
        url: '/admin/ignored_files', 
        data: {'ignored': !($(this).is(':checked')), query: query}
    })
  })


  $(document).on('change', '.primary', function(){
    id = this.id;
    $(".primary#"+id).prop('disabled', true);
    $.ajax({
        type: 'patch',
        url: "/admin/ignored_files/"+id+"/update_ignore_field",
        data: {'ignored_value': this.checked}
    })
  })

});