const path = require('path')
const HtmlWebpackPlugin = require('html-webpack-plugin')

module.exports = {
  entry: path.join(__dirname, '/connector-embed.js'),
  output: {
    path: path.join(__dirname, '../../dist/connector-embed'),
    publicPath: '',
    filename: 'bundle.js'
  },
  module: {
    loaders: [
      { test: /\.(js|jsx)$/,
        loader: 'babel',
        query: {
          presets: [ 'es2015', 'react', 'stage-2' ],
          plugins: [ 'lodash' ]
        }
      },
      { test: /\.jade$/, loader: 'jade' }
    ]
  },
  plugins: [
    new HtmlWebpackPlugin({
      inject: false,
      template: path.join(__dirname, '/index.jade'),
      filename: 'index.html'
    })
  ]
}