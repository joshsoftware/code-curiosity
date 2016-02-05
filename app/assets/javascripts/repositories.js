
$(document).on("paste", "#repository_source_url", function(e){
  url = e.originalEvent.clipboardData.getData('text');
  url = url.replace(/(http|https):\/\/github.com\//, "");
  url = url.replace(/\.git$/, '');
  $(this).val(url);
  return false;
});
