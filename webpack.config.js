const path = require('path')

const webpack = require('webpack')
const Copy = require('copy-webpack-plugin')

//const nodeEnv = progress.env.NODE_ENV || 'development'

module.exports = {
    entry: {
      index:'./lib/index/index.js',
      terminal:'./lib/terminal/index.js',
      device: './lib/device/index.js',
      request_analysis: './lib/request_analysis/index.js'
    },
    output: {
        path: './app/dist',
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
