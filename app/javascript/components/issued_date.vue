<template>
  <div class="document-issued-date">
    <template v-for="value in values">
      <div>Issued Date: {{ value }}</div>
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
