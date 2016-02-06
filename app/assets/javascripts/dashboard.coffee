# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@load_repos = (repos) ->
  if repos.length == 0
     return

  template  = Mustache.compile($.trim($("#template").html()))
  view      = (record, index) ->
    template(record: record, index: index)

  options = {
    view: view,
    search_box: "#repo-search-box"
    pagination: {
      container: "#repos-pagination",
      ul_class: "pagination pagination-sm no-margin",
      next_text: "»",
      prev_text: "«",
      per_page_select: false
    }
  }

  $("#stream_table").stream_table(options, repos)

$(document).on "page:change", ->
  $('#datepicker1').datepicker format: 'dd/mm/yyyy'
  
$(document).on "change", "td.score select", ->
  params = $(this).closest("tr").data()
  params["rank"] = $(this).val()
  $.post("/score", params)
