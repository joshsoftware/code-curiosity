# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@set_multiselect = ->
  $("#team_members").multiselect({enableFiltering: true})
  apply_multiselect("#teams select")


@apply_multiselect  = (element) ->
  $(element).multiselect({
    enableFiltering: true
    onChange: (element, checked) ->
      selected_repos = $(element).closest("select").val()
      $.ajax(
        {
          type: 'put'
          data: {repos: selected_repos}
          url:  "teams/#{$(element).closest("tr").data("team")}"
        }
      )
  })

$(document).on "change", "td.score select", ->
  params = $(this).closest("tr").data()
  params["rank"] = $(this).val()
  $.post("/score", params)

  
