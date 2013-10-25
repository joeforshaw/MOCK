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
