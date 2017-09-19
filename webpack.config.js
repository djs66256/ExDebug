const path = require('path')

const webpack = require('webpack')
const Copy = require('copy-webpack-plugin')

//const nodeEnv = progress.env.NODE_ENV || 'development'

module.exports = {
    entry: {
      index: path.join(__dirname, 'lib/index/index.js'),
      terminal: path.join(__dirname, 'lib/terminal/index.js'),
      device: path.join(__dirname, 'lib/device/index.js'),
      request_analysis: path.join(__dirname, 'lib/request_analysis/index.js')
    },
    output: {
        path: path.join(__dirname, 'app/dist'),
        filename: '[name].js'
    },
    module: {
        loaders: [
            {
                test: /\.js$/,
                exclude: /node_modules/,
                loader: 'babel-loader'
            },
            {
              test: /\.css$/,
              use: [ 'style-loader', 'css-loader' ]
            }
        ]
    },
    devtool: "source-map",
    target: 'electron'
}
