const { webpackConfig, merge } = require('shakapacker')

// See the shakacode/shakapacker README and docs directory for advice on customizing your webpackConfig.

// config/webpack/webpack.config.js

const customConfig = {
  resolve: {
    extensions: ['.css', '.scss']
  }
}

module.exports = merge(webpackConfig, customConfig)
