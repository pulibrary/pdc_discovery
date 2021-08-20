<template>
  <div class="document-methods">
    <header>Methods:</header>
    <template v-for="value in values">
      <span class="document-methods--value">{{ values }}</span>
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
};
</script>
