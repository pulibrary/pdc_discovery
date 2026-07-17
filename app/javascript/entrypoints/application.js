// Vite application entrypoint

// 1. Initialize jQuery first to ensure it's on window for Bootstrap and Blacklight
import $ from '../jquery.js';

// 2. Import styles
import '../styles/application.scss';

// 3. Import Rails UJS & Turbolinks
import Rails from '@rails/ujs';
Rails.start();

import Turbolinks from 'turbolinks';
Turbolinks.start();

// 4. Import Plausible tracking script
import '../plausible.js';

// 5. Import Popper & Bootstrap
import 'popper.js';
import 'bootstrap';

// 6. Import Blacklight and typeahead autocomplete
import 'blacklight-frontend';
import '../vendor/twitter/typeahead/typeahead.bundle.js';
import DataTable from 'datatables.net';
import 'datatables.net-dt';
DataTable.use($);

// 7. Import vendored blacklight_range_limit ESM
import '../vendor/blacklight_range_limit/blacklight_range_limit.esm.js';

// Custom inline scripting from original application.js
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

// 8. Flush any queued inline jQuery ready handlers and event listeners
if (window._jqQueue) {
  window._jqQueue.forEach(item => {
    try {
      if (item.type === 'ready') {
        $(item.handler);
      } else if (item.type === 'on') {
        $(item.selector).on(item.event, item.handler);
      }
    } catch (e) {
      console.error('Error executing queued jQuery item:', e);
    }
  });
  delete window._jqQueue;
}

