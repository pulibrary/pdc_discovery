<template>
  <div class="document-authors">
    <template v-for="author in authors">
      <a href="#" class="document-author">{{ author }}</a>
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
    authors: function () {
      return this.values.map((value, i) => {
        return value + (i < this.values.length - 1 ? ", " : "");
      });
    },
  },
};
</script>
