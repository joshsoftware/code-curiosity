
(function($, window, document) {

  "use strict";

  window.GHSTORE = {};

  var API_URL = 'https://api.github.com/';

  var GhApi = function(username) {
    if(!username){
      username = $('#gh-user').data('login');
    }

    return new GA(username);
  };

  window.GhApi = GhApi;

  var GA = function(username) {
    this.username = username;
  };

  GA.prototype.get = function(uriComponents, callback){
    var uri = uriComponents.join('/');

    if(GHSTORE[uri]){
      callback(GHSTORE[uri]);
      return;
    }

    $.getJSON('https://api.github.com/' + uri, function(result){
      GHSTORE[uri] = result;     
      callback(GHSTORE[uri]);
    });
  };

  GA.prototype.orgs = function(callback){
    console.log(this)
    this.get(['users', this.username, 'orgs'], callback);
  };
  

})( jQuery, window , document );
