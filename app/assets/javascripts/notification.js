$.noty.defaults.timeout = 3000;
$.noty.defaults.theme = "relax";
$.noty.defaults.type = "notification"

window.flashNotification = function(message, type){
  if(type == "notice" || !type){
    type = "information"
  }

  noty({text: message, type: type, layout: 'topRight' });
}
