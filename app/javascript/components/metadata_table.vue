<template>
  <div class="card">
    <div class="document-metadata-table card-body">
      <header>More about this record</header>
      <table class="table">
        <thead></thead>
        <tbody>
          <template v-for="tuple in values">
            <template v-for="value in tuple.values">
              <tr>
                <th scope="row">
                  <span>
                    <span>{{ tuple.label }}</span>
                  </span>
                </th>
                <td>
                  <span>
                    <span>{{ value }}</span>
                  </span>
                </td>
              </tr>
            </template>
          </template>
        </tbody>
        <tfoot>
          <tr>
            <th scope="row">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                width="16"
                height="16"
                fill="currentColor"
                class="bi bi-caret-down"
                viewBox="0 0 16 16"
              >
                <path
                  d="M3.204 5h9.592L8 10.481 3.204 5zm-.753.659 4.796 5.48a1 1 0 0 0 1.506 0l4.796-5.48c.566-.647.106-1.659-.753-1.659H3.204a1 1 0 0 0-.753 1.659z"
                />
              </svg>
              <a class="document-metadata-table__expand" href="/">Show More</a>
            </th>
            <td></td>
          </tr>
        </tfoot>
      </table>
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
