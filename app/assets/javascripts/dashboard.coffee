# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@load_repos = (repos) ->
  template  = Mustache.compile($.trim($("#template").html()))
  view      = (record, index) ->
    template(record: record, index: index)

  $("#stream_table").stream_table({view: view}, repos)

$ ->
  $('#datepicker1').datepicker format: 'dd/mm/yyyy'

  
