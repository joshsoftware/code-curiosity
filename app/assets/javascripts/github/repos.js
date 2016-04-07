
function renderOrgsMenu(){
  var tpl = $("#org-href-tpl").html();
  var container = $("#orgs-list");

  GhApi().orgs(function(orgs){
    $.each(orgs, function(){
      var html = Mustache.render(tpl, this);   
      container.append(html);
    });    
  });
}

function refreshPageOnInteval(){
  window.pageRefreshInterval = setInterval(function(){
    Turbolinks.visit(location.toString());
  }, 60*1000)
}

$(document).on('shown.bs.tab', 'a.gh-org-repos', function (e) {
  $('#gh-orgs-title h3').text('Fetching.....');
  
  var attrs = { href: $(this).data('href') };

  $.rails.handleRemote($('<a>', attrs)); 
})

