$("#solution-nav").on("click", function() {
  $("#pareto-front-page").hide();
  $("#solution-page").animate({
    $(this).show();
  });
});

$("#pareto-front-nav").on("click", function() {
  $("#solution-page").hide();
  $("#pareto-front-page").animate({
    $(this).show();
  });
});