<template>
  <div class="card">
    <div class="document-downloads card-body">
      <table class="table">
        <thead>
          <tr>
            <th scope="col" nowrap="nowrap">
              <span>#</span>
            </th>
            <th scope="col" nowrap="nowrap">
              <span>Filename</span>
            </th>
            <th scope="col" nowrap="nowrap">
              <span>Filesize</span>
            </th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="(value, index) in values"
            :key="index"
            class="document-download"
          >
            <th scope="row">
              <span>
                <span>{{ index + 1 }}</span>
              </span>
            </th>
            <td>
              <span>
                <a :href="value.fileName.href">{{ value.fileName.content }}</a>
              </span>
            </td>
            <td>
              <span>
                <span>{{ value.fileSize }}</span>
              </span>
            </td>
          </tr>
        </tbody>
        <tfoot></tfoot>
      </table>
      <input-button
        type="button"
        variation="solid"
        class="document-downloads__button"
        >Download from Globus</input-button
      >
    </div>
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
