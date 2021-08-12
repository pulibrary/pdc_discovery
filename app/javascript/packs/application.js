// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Vue from "vue/dist/vue.esm";
import system from "lux-design-system";
import "lux-design-system/dist/system/system.css";
import "lux-design-system/dist/system/tokens/tokens.scss";

// Import all CSS assets into Webpack
import "styles/application";

Vue.use(system);

import Authors from "components/authors";
import IssuedDate from "components/issued_date";
import Abstract from "components/abstract";
import Description from "components/description";
import Methods from "components/methods";

document.addEventListener("DOMContentLoaded", () => {
  var elements = document.getElementsByClassName("lux");
  for (var i = 0; i < elements.length; i++) {
    new Vue({
      el: elements[i],
      components: {
        authors: Authors,
        "issued-date": IssuedDate,
        abstract: Abstract,
        description: Description,
        methods: Methods,
      },
    });
  }
});
