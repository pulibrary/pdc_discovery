<template>
  <div class="document-methods">
    <header>Methods:</header>
    <template v-for="method in methods">
      <span class="document-methods--value">{{ method }}</span>
    </template>
  </div>
</template>

<script>
export default {
  props: {
    values: {
      type: Array,
      default: [],
    },
  },
  computed: {
    methods: function () {
      return this.values.map((value, i) => {
        return value + (i < this.values.length - 1 ? ", " : "");
      });
    },
  },
};
</script>
