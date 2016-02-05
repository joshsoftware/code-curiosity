# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@load_repos = (repos) ->
  template  = Mustache.compile($.trim($("#template").html()))
  view      = (record, index) ->
    template(record: record, index: index)

  $("#stream_table").stream_table({view: view}, repos)

$(document).on "page:change", ->
  $('#datepicker1').datepicker format: 'dd/mm/yyyy'

  
$(document).on "change", "td.score select", ->
  params = $(this).closest("tr").data()
  params["rank"] = $(this).val()
  $.post("/score", params)


  
window.show_notification = (text, type)->
  $.noty.closeAll()
  window.noty_obj = noty({
    layout: 'topCenter'
    text: text
    type: type
    theme: 'relax'
    closeWith: 'click'
    animation:
      open: "animated bounceInRight"
      close: "animated bounceOutRight"
  })
  # if not close automatically
  setTimeout (->
      $.noty.closeAll()
    ), 3000

window.close_noty_in = (time)->
  setTimeout (->
      $.noty.closeAll()
    ), time


$(document).on 'submit', "#new_repository", ->
  parent_obj = $("#repository_source_url").closest(".form-group")
  parent_obj.removeClass("has-error")
  $(this).find("span").remove()
  
  if $("#repository_source_url").val() == ""
    parent_obj.addClass("has-error")
    parent_obj.append("<span class='help-block text-danger'>can't be blank</span>")
    return false
  else
    return true
