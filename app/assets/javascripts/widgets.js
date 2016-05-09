//= require jquery
//= require jquery_ujs
//= require turbolinks

function resizeWidgetIframe(frame) {
  frame.style.height = frame.contentWindow.document.body.scrollHeight + 'px';
}
