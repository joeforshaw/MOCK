$(document).ready(function() {
  $('li.index-list-item').click(function(e) {
    e.preventDefault();
    $("#options-" + $(this).attr("id")).slideToggle(300);
  });
});

$(function() {
  if ($(".run-create").length > 0) {
    $(".run-create").spin();
    setTimeout(isComplete, 2000);
  }
});

function isComplete() {
  var runID = $(".run-create").attr("data-id");
  $.getScript("/runs/" + runID + ".js?id=" + runID);
  setTimeout(isComplete, 2000);
}
