$(".nav-tab").on("click", function() {
  $(".active-tab").removeClass("active-tab");
  $($(this).data("tab")).addClass("active-tab");
});