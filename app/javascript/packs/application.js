// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

//import Rails from "@rails/ujs" // This needs to be disabled for Blacklight integration
//import Turbolinks from "turbolinks" // This must remain disabled for optimal integration with LUX
import * as ActiveStorage from "@rails/activestorage";
import "channels";

// Import all CSS assets into Webpack
import "styles/application";

//Rails.start() // This needs to be disabled for Blacklight integration
//Turbolinks.start() // This must remain disabled for optimal integration with LUX
ActiveStorage.start();

console.log("Hello World from Webpack!");
