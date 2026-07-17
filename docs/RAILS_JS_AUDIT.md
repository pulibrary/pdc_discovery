# Comprehensive JavaScript Integration Audit: PDC Discovery

This document details the status, critical issues, configuration mismatches, and recommended architectural roadmaps for the JavaScript and frontend integration in **PDC Discovery**.

---

## 1. Executive Summary

**Status**: ⚠️ **Major Concerns**

While the application successfully runs and passes its Ruby-based system/browser specs (`spec/system`), the JavaScript ecosystem within this repository is in a **highly fragmented, transitional, and misconfigured state**.

Key findings include:

* **Dead-Weight Tooling**: A complete Vite configuration (`vite_rails`, `vite.config.mts`, `app/javascript/entrypoints/`) is installed but **entirely bypassed** in layout templates, which still load legacy Sprockets assets.
* **Broken Linting/Formatting Suite**: Standard linting commands fail due to parser misconfigurations, and Stylelint crashes completely on execution due to mismatched major versions.
* **Orphaned Configuration Files**: Configuration files like `babel.config.js` remain from retired bundlers (Webpacker) but cannot run because their underlying dependencies do not exist.
* **Deprecated Libraries**: The application relies on outdated libraries such as Turbolinks (deprecated in favor of Hotwire Turbo) and Bootstrap 4 (EOL).

---

## 2. Issues Found & Detailed Analysis

### 🔍 Issue 1: Unused Vite Integration (Hybrid / Transitional State)

* **Context**: `app/views/layouts/blacklight/base.html.erb` vs `app/javascript/entrypoints/application.js` and `Gemfile`
* **Details**: The codebase includes the `vite_rails` gem, NPM `vite`, `vite-plugin-ruby`, and a Vite directory structure under `app/javascript/`. However, the main layout (`base.html.erb`) still references legacy Sprockets pipelines:

  ```erb
  <%= stylesheet_link_tag "application", media: "all" %>
  <%= javascript_include_tag "application" %>
  ```

  No Vite tags (`vite_javascript_tag` or `vite_client_tag`) are rendered. The current Vite installation is dead weight, consuming resources and creating confusion.

---

### 🔍 Issue 2: Broken ESLint Parser Configuration

* **Context**: `.eslintrc.js`
* **Details**: Running `yarn eslint .` produces immediate parsing crashes:

  ```
  app/javascript/channels/consumer.js:  Parsing error: The keyword 'import' is reserved
  app/javascript/channels/index.js:  Parsing error: The keyword 'const' is reserved
  ```

  This happens because `.eslintrc.js` is configured to only extend `prettier` without specifying an ECMAScript version or module source type. Modern ES6+ keywords and module structures are not recognized.

---

### 🔍 Issue 3: Stylelint Configuration Crash (Major Dependency Mismatch)

* **Context**: `package.json` vs `.stylelintrc.json`
* **Details**: Attempting to run Stylelint crashes with:

  ```
  TypeError: text2.charAt is not a function at diff_commonPrefix ... in stylelint-prettier
  ```

  This is a critical mismatch. `package.json` specifies `"stylelint": "^16.26.1"` (Stylelint v16) but pairs it with `"stylelint-prettier": "^1.2.0"`. Stylelint v16 requires `stylelint-prettier` **v5.0.0+**. Additionally, `"stylelint-config-prettier"` is obsolete since Stylelint v15 and should be removed.

---

### 🔍 Issue 4: Orphaned Webpacker/Babel Configuration

* **Context**: `babel.config.js`
* **Details**: This file remains as a leftover from Webpacker. It contains extensive instructions for loading `@babel/preset-env`, `babel-plugin-macros`, etc. However, **none of these Babel packages are installed** in `package.json`. If any tool invokes Babel, it will fail immediately.

---

### 🔍 Issue 5: Bloated Package Dependencies

* **Context**: `package.json`
* **Details**:
  * `"esbuild": "^0.28.1"` is declared directly under `dependencies`. Since Vite manages its own esbuild execution, this explicit dependency is redundant.
  * `"lodash": "^4.18.1"`, `"color-string"`, `"glob-parent"`, and `"picomatch"` are listed in `dependencies` but are **never imported or used** anywhere in `app/`. It appears these were added to resolve security alerts instead of utilizing Yarn's resolution mechanism.
  * `"turbolinks": "^5.2.0"` is loaded but has been deprecated for several years.

---

## 3. Suggested Short-Term Fixes

### 🛠️ Fix 1: Fix ESLint Configuration

Update `.eslintrc.js` to support ES6+ syntax, modern modules, and the browser environment:

```javascript
// .eslintrc.js
module.exports = {
  env: {
    browser: true,
    es2021: true,
    node: true
  },
  parserOptions: {
    ecmaVersion: 'latest',
    sourceType: 'module'
  },
  extends: ['eslint:recommended', 'prettier'],
  rules: {
    'no-unused-vars': 'warn',
    'no-console': 'off'
  }
};
```

---

### 🛠️ Fix 2: Upgrade Stylelint Packages & Configuration

Align stylelint packages to resolve the runtime `TypeError` crash:

1. Update package declarations:

   ```bash
   yarn remove stylelint-config-prettier
   yarn add -D stylelint-prettier@^5.0.0
   ```

2. Simplify `.stylelintrc.json` to eliminate deprecated configuration files:

   ```json
   {
     "extends": ["stylelint-prettier/recommended"],
     "plugins": ["stylelint-scss"],
     "rules": {
       "at-rule-no-unknown": null,
       "scss/at-rule-no-unknown": true
     }
   }
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
   * Move the CSS/JS files from `app/assets/` to `app/javascript/`.
   * Update `app/views/layouts/blacklight/base.html.erb` to load Vite entrypoints:

     ```erb
     <%= vite_client_tag %>
     <%= vite_javascript_tag 'application' %>
     ```

   * Remove the `dartsass-sprockets`, `jquery-rails`, and other asset pipeline gems that are no longer needed.

### Recommendation B: Clean Up Redundant Configs & Unused Packages

* Remove the orphaned `babel.config.js` file since Vite handles ES compilation out-of-the-box using Esbuild/Rollup.
* Remove unused packages like `lodash`, `color-string`, `glob-parent`, and `picomatch` from the top-level dependencies. If transitive dependencies have security vulnerabilities, use Yarn's `resolutions` block in `package.json` rather than adding them as direct production dependencies.

### Recommendation C: Migrate from Turbolinks to Turbo

* Since the project uses Rails 8.1, replace the outdated and deprecated `turbolinks` with `@hotwired/turbo-rails` (Turbo). This modernizes the page-loading system, resolves compatibility edge-cases with modern JS libraries, and aligns the stack with modern Rails standards.
