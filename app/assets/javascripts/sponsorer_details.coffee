# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on "ready", ->
  $('body').on 'change', '.sponsorer_detail_avatar', () ->
    inputFile = $(this).val();
    validateFiles(inputFile);
  if window.location.pathname == '/sponsorer_details'
    showmodal();

showmodal = () ->
  if modal == "true"
    $("#rotate").click();

validateFiles = (inputFile) ->
  extErrorMessage = 'Only image file with extension: .jpg, .jpeg, .gif or .png is allowed'
  allowedExtension = [
    'jpg'
    'jpeg'
    'gif'
    'png'
  ]
  extName = inputFile.split('.').pop()
  extError = false
  if $.inArray(extName, allowedExtension) == -1
    window.alert extErrorMessage
    $(inputFile).val ''
    $(this).val ''
  return