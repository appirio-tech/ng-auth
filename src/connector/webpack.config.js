const path = require('path')
const HtmlWebpackPlugin = require('html-webpack-plugin')

process.env.API_URL = 'https://api-work.topcoder-dev.com'

require('coffee-script/register');

const config = require('appirio-tech-webpack-config')({
  dirname: __dirname
});

module.exports = Object.assign(config, {
  entry: path.join(__dirname, '/connector-embed.js'),
  output: {
    path: path.join(__dirname, '../../dist/connector-embed'),
    publicPath: '',
    filename: 'bundle.js'
  },
  plugins: [
    new HtmlWebpackPlugin({
      inject: false,
      template: path.join(__dirname, '/index.jade'),
      filename: 'index.html'
    })
  ]
})