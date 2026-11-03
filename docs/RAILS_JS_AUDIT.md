# Comprehensive JavaScript Integration Audit: PDC Discovery

This document details the status, critical issues, configuration mismatches, and recommended architectural roadmaps for the JavaScript and frontend integration in **PDC Discovery**.

---

## 1. Executive Summary

**Status**: ⚠️ **Major Concerns**

While the application successfully runs and passes its Ruby-based system/browser specs (`spec/system`), the JavaScript ecosystem within this repository is in a **highly fragmented, transitional, and misconfigured state**.

Key findings include:

- **Dead-Weight Tooling**: A complete Vite configuration (`vite_rails`, `vite.config.mts`, `app/javascript/entrypoints/`) is installed but **entirely bypassed** in layout templates, which still load legacy Sprockets assets.
- **Broken Linting/Formatting Suite**: Standard linting commands fail due to parser misconfigurations, and Stylelint crashes completely on execution due to mismatched major versions.
- **Deprecated Libraries**: The application relies on outdated libraries such as Turbolinks (deprecated in favor of Hotwire Turbo) and Bootstrap 4 (EOL).

---

## 2. Issues Found & Detailed Analysis

### 🔍 Issue 1: Unused Vite Integration (Hybrid / Transitional State)

- **Context**: `app/views/layouts/blacklight/base.html.erb` vs `app/javascript/entrypoints/application.js` and `Gemfile`
- **Details**: The codebase includes the `vite_rails` gem, NPM `vite`, `vite-plugin-ruby`, and a Vite directory structure under `app/javascript/`. However, the main layout (`base.html.erb`) still references legacy Sprockets pipelines:

  ```erb
  <%= stylesheet_link_tag "application", media: "all" %>
  <%= javascript_include_tag "application" %>
  ```

  No Vite tags (`vite_javascript_tag` or `vite_client_tag`) are rendered. The current Vite installation is dead weight, consuming resources and creating confusion.

---

### 🔍 Issue 2: Broken ESLint Parser Configuration

- **Context**: `.eslintrc.js`
- **Details**: Running `yarn eslint .` produces immediate parsing crashes:

  ```
  app/javascript/channels/consumer.js:  Parsing error: The keyword 'import' is reserved
  app/javascript/channels/index.js:  Parsing error: The keyword 'const' is reserved
  ```

  This happens because `.eslintrc.js` is configured to only extend `prettier` without specifying an ECMAScript version or module source type. Modern ES6+ keywords and module structures are not recognized.


---

### 🛠️ Fix 2: Upgrade Stylelint Packages & Configuration

Align stylelint packages to resolve the runtime `TypeError` crash:

1. Update package declarations:

   ```bash
   yarn remove stylelint-config-prettier
   yarn add -D stylelint-prettier@^5.0.0
   ```
---

### 🛠️ Fix 3: Standardize Package Scripts

Provide clear, comprehensive linting scripts in `package.json` that include ESLint and Stylelint rather than relying solely on Prettier checks:

```json
"scripts": {
  "lint:format": "prettier --check \"app/{javascript,assets}/**/*.{js,css,scss}\"",
  "lint:js": "eslint \"app/{javascript,assets/javascripts}/**/*.js\"",
  "lint:css": "stylelint \"app/{javascript,assets/stylesheets}/**/*.{css,scss}\"",
  "lint": "yarn run lint:format && yarn run lint:js && yarn run lint:css",
  "lint:fix": "prettier --write \"app/{javascript,assets}/**/*.{js,css,scss}\" && eslint --fix \"app/{javascript,assets/javascripts}/**/*.js\""
}
```

---

## 4. Architectural Recommendations & Roadmaps

### Recommendation A: Decisive Action on Vite Bundling (The Clean Approach)

To align with modern Rails best practices, the project should choose one of two paths:

1. **Complete the Vite Migration (Recommended)**:
   - Move the CSS/JS files from `app/assets/` to `app/javascript/`.
   - Update `app/views/layouts/blacklight/base.html.erb` to load Vite entrypoints:

     ```erb
     <%= vite_client_tag %>
     <%= vite_javascript_tag 'application' %>
     ```

   - Remove the `dartsass-sprockets`, `jquery-rails`, and other asset pipeline gems that are no longer needed.

### Recommendation B: Clean Up Redundant Configs & Unused Packages

- Remove the orphaned `babel.config.js` file since Vite handles ES compilation out-of-the-box using Esbuild/Rollup.
- Remove unused packages like `lodash`, `color-string`, `glob-parent`, and `picomatch` from the top-level dependencies. If transitive dependencies have security vulnerabilities, use Yarn's `resolutions` block in `package.json` rather than adding them as direct production dependencies.

### Recommendation C: Migrate from Turbolinks to Turbo

- Since the project uses Rails 8.1, replace the outdated and deprecated `turbolinks` with `@hotwired/turbo-rails` (Turbo). This modernizes the page-loading system, resolves compatibility edge-cases with modern JS libraries, and aligns the stack with modern Rails standards.
