
$(document).on('page:change', function(event) {
  setupUserSearch();

  $('form.add-members').on('ajax:complete', function(xhr, status) {
     afterUserInvited();
  });
})

function setupUserSearch(){
  var $ele = $('#search-users');
  var selectedMember;

  if($ele.length == 0){ return ; }

  $ele.typeahead({
    ajax: { 
      url: $ele.data('url'),
      triggerLength: $ele.data('min-length') || 1,
      preProcess: function(data){
        data.forEach(function(d){
          d.full_name = d.github_handle + ( d.name ? ' (' + d.name + ')' : '')
        })
        return data;
      },
    },
    valueField: '_id',
    displayField: 'full_name',
    onSelect: function(item){
      console.log(item)
      $('#new-member-id').val(item.value);
    }
  });
}

function afterUserInvited(){
  $('#new-member-id').val('');
  $('#search-users').val('');
}
