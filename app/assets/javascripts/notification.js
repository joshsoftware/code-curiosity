$.noty.defaults.timeout = 5000;
$.noty.defaults.theme = "relax";
$.noty.defaults.type = "notification"

window.flashNotification = function(message, type, timeout){
  if(type == "notice" || !type){
    type = "information"
  }

  noty({text: message, type: type, layout: 'topRight', timeout: timeout });
}
