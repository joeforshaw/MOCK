$(function() {
  if ($(".run-create").length > 0) {
    $(".run-create").spin();
    isComplete();
  }
});

function isComplete() {
  var runID = $(".run-create").attr("data-id");
  $.getScript("/runs/" + runID + ".js?id=" + runID);
  setTimeout(isComplete, 10000);
}