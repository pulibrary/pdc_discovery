//= require jquery
//= require jquery3
//= require rails-ujs
//= require turbolinks
//= require plausible
//
// Required by Blacklight
//= require popper
// Twitter Typeahead for autocomplete
//= require twitter/typeahead
//= require bootstrap
//= require blacklight/blacklight

// For blacklight_range_limit built-in JS, if you don't want it you don't need
// this:
//= require 'blacklight_range_limit'

$(function () {
  // Force focus to the first input box as soon as the modal is shown to the user
  // https://getbootstrap.com/docs/4.0/components/modal/
  $('#contactUsModal').on('shown.bs.modal', function (e) {
    $('#name').focus();
  });

  // Validate form elements before submitting
  // https://developer.mozilla.org/en-US/docs/Web/HTML/Constraint_validation
  $('#contact-us-submit').on('click', function () {
    var form = $('#contact-us-form')[0];
    if (form.reportValidity() === true) {
      form.submit();
    }
  });
});
