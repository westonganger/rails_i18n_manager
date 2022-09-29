window.init = function(){
  $("form").attr("autocomplete", "off");

  $('.field_with_errors').addClass('is-invalid');

  var alerts = $(".alert:not(.permanent)")
  setTimeout(function(){
    alerts.fadeOut();
  }, 8000);

  autosize($('textarea'));

  $("select").each(function(){
    $(this).removeClass("form-select");

    new SlimSelect({
      select: this,
      settings: {
        //contentLocation: document.body,
        contentLocation: this.parentElement,
        closeOnSelect: !this.hasAttribute("multiple"),
        openPosition: 'down', // options: auto, up, down
        //placeholderText: "Select Value",
        placeholderText: "Select...",
        //searchPlaceholder: 'Search',
        //searchText: 'No Results',
        //searchingText: 'Searching...',
        maxValuesShown: 999, // defaults to 20, max selected items show in multi-selects
        //maxValuesShown: 20,
      }
    })
  });
}

$(function(){
  window.init();
});
