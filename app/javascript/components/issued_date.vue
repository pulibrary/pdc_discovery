<template>
  <div class="document-issued-date">
    <div>Issued Date: {{ value }}</div>
  </div>
</template>

<script>
export default {
  props: {
    value: {
      type: String,
      default: null,
    },
  },
};
</script>
