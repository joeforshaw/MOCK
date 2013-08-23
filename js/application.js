$("#pareto-front-page").hide();

$("#solution-nav").on("click", function() {
  $("#pareto-front-page").hide();
  $("#solution-page").show();
});

$("#pareto-front-nav").on("click", function() {
  $("#solution-page").hide();
  $("#pareto-front-page").show();
});