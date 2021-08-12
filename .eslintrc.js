module.exports = {
    extends: [
          'plugin:vue/recommended',
          'plugin:prettier-vue/recommended',
          'prettier',
        ],
  settings: {
        'prettier-vue': {
          // Settings for how to process Vue SFC Blocks
          SFCBlocks: {
            template: true
            script: true,
            style: true,

            // Settings for how to process custom blocks
            customBlocks: {
              // Treat the `<docs>` block as a `.markdown` file
              docs: { lang: 'markdown' },
              // Treat the `<config>` block as a `.json` file
              config: { lang: 'json' },
              // Treat the `<module>` block as a `.js` file
              module: { lang: 'js' },
              // Ignore `<comments>` block (omit it or set it to `false` to ignore the block)
              comments: false
            }
          },
          // Use prettierrc for prettier options or not (default: `true`)
          usePrettierrc: true,
          fileInfoOptions: {
            // Path to ignore file (default: `'.prettierignore'`)
            ignorePath: '.prettierignore',
            // Process the files in `node_modules` or not (default: `false`)
            withNodeModules: false,
          }
        }
  },
  rules: {
    // Override all options of `prettier` here
    // @see https://prettier.io/docs/en/options.html
    'prettier-vue/prettier': [
    ]
  }
}
