$(document).on('page:change', function(event) {
  $(document).ready(function() {
    function addDatePicker(){
      $('.datepicker').datepicker({
        format: 'dd M yyyy',
        startDate: '0d',
        orientation: "bottom auto",
        autoclose: true
      })
    };

    $(".sponsor_form").on( "click", ".is_all_repos", function() {
      var closestSelect = $(this).closest('.fields').find('select.budget_repo_ids')
      if($(this).is(':checked')){
        closestSelect.prop('disabled', true);
      }
      else{
        closestSelect.prop('disabled', false);
      }
    });

    function addSelect2(){
      $('select.budget_repo_ids').select2({
        ajax: {
          type: 'get',
          url: '/repositories/search',
          dataType: 'json',
          delay: 250,
          data: function (params) {
            return {
              query: params.term,
            };
          },
          processResults: function (data) {
                            return {
                              results: data,
                            };
                          },
          cache: true
        },
        placeholder: 'Select a Repository',
        dropdownAutoWidth: 'true',
        width: '100%',
        closeOnSelect: true,
      })
    }

    $(document).on('nested:fieldAdded', function(event){
      addSelect2();
      addDatePicker();
    })

    addSelect2();
    addDatePicker();
  });
});
