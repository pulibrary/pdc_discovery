# Upgrading and Bundling DataTables 2.x with Vite

This guide describes the steps taken to migrate **DataTables** from an external CDN-based script to a fully bundled Yarn dependency managed by Vite. It also outlines the diagnostic and troubleshooting steps used to resolve common integration issues such as duplicate jQuery instances and deferred script race conditions.

---

## 1. Problem & Context
Previously, DataTables was loaded via a third-party CDN script tag in `app/views/layouts/blacklight/base.html.erb`:
```html
<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.11.3/css/jquery.dataTables.min.css"/>
<script type="text/javascript" src="https://cdn.datatables.net/1.11.3/js/jquery.dataTables.min.js"></script>
```

This setup presented two major issues under Vite:
1. **Deferred Execution Race Condition**: Vite loads JavaScript entrypoints as asynchronous deferred ES Modules (`<script type="module">`). Conversely, CDN scripts load synchronously. This meant the CDN-based DataTables script executed *before* jQuery had been initialized on `window.$` by the Vite bundle, causing silent registration failures.
2. **Strict-mode ESM Requirements**: Modern ES Module packaging in DataTables 2.x does not implicitly modify global variables or attach itself to `window.jQuery` automatically without explicit registration.

---

## 2. Step-by-Step Migration Guide

### Step 1: Install DataTables packages via Yarn
Install the core DataTables package and its default styling package:
```bash
yarn add datatables.net datatables.net-dt
```

### Step 2: Unify jQuery Versions (Preventing Duplication)
By default, the installed DataTables packages declare dependency on any jQuery version `>=1.7` and can resolve to `jquery@4.x` in Yarn 4. Meanwhile, the project workspace uses `jquery@3.x`. 

If multiple jQuery versions are bundled, DataTables registers itself on jQuery v4's prototype, while your application uses jQuery v3, leading to `TypeError: $(...).DataTable is not a function`.

To enforce a single, unified copy of jQuery across the entire dependency tree, add a `resolutions` block in `package.json`:
```json
{
  "resolutions": {
    "jquery": "^3.7.1"
  }
}
```
Run `yarn install` and verify with `yarn why jquery` that both `datatables.net` and your workspace point to the exact same version.

### Step 3: Register DataTables on jQuery in Vite Entrypoint
In `app/javascript/entrypoints/application.js`, import the core DataTables package, styling package, and explicitly register it on the imported jQuery instance using the DataTables 2 `.use()` method:

```javascript
import $ from '../jquery.js';
import DataTable from 'datatables.net';
import 'datatables.net-dt';

// Explicitly register the jQuery instance on DataTables 2
DataTable.use($);
```

### Step 4: Import DataTables Styling
In `app/javascript/styles/application.scss`, import the DataTables styling package:
```scss
@import "datatables.net-dt/css/dataTables.dataTables.css";
```

### Step 5: Clean Up Layout Files
Remove the legacy CDN style and script tags from `app/views/layouts/blacklight/base.html.erb`:
```html
<!-- REMOVE these lines -->
<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.11.3/css/jquery.dataTables.min.css"/>
<script type="text/javascript" src="https://cdn.datatables.net/1.11.3/js/jquery.dataTables.min.js"></script>
```

---

## 3. Handling Inline/Embedded Scripts
To support inline view templates that call `$('#files-table').DataTable({...})` before the main Vite ES module has loaded, the layout uses a chainable jQuery event-queueing stub inside the `<head>` tag:

```html
<script type="text/javascript">
  window._jqQueue = window._jqQueue || [];
  window.jQuery = window.$ = function(selector) {
    if (typeof selector === 'function') {
      window._jqQueue.push({ type: 'ready', handler: selector });
      return window.$;
    }
    
    var dummy = {
      click: function(handler) {
        if (typeof handler === 'function') {
          window._jqQueue.push({ type: 'on', selector: selector, event: 'click', handler: handler });
        }
        return dummy;
      },
      on: function(event, handler) {
        if (typeof handler === 'function') {
          window._jqQueue.push({ type: 'on', selector: selector, event: event, handler: handler });
        }
        return dummy;
      },
      ready: function(handler) {
        if (typeof handler === 'function') {
          window._jqQueue.push({ type: 'ready', handler: handler });
        }
        return dummy;
      },
      // Stubs for other chainable/immediate calls
      focus: function() { return dummy; },
      addClass: function() { return dummy; },
      removeClass: function() { return dummy; },
      text: function() { return ''; },
      toggleClass: function() { return dummy; },
      DataTable: function() { return dummy; }
    };
    return dummy;
  };
</script>
```

At the end of `application.js`, this queue is flushed and correctly bound once jQuery and DataTables are loaded:
```javascript
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
```

---

## 4. Compilation & Verification
Ensure assets are rebuilt cleanly:
```bash
# Compile development/production assets
bin/vite clobber && bin/vite build

# Compile test environment assets
RAILS_ENV=test bin/vite clobber && RAILS_ENV=test bin/vite build
```

Verify that system specs containing files-tables (such as `spec/system/show_pdc_describe_record_spec.rb`) run and pass successfully:
```bash
bundle exec rspec spec/system/show_pdc_describe_record_spec.rb
```
