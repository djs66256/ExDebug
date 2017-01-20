const path = require('path')

const webpack = require('webpack')
const Copy = require('copy-webpack-plugin')

//const nodeEnv = progress.env.NODE_ENV || 'development'

module.exports = {
    entry: {
      index:'./lib/index/index.js',
      terminal:'./lib/terminal/index.js'
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
            }
        ]
    },
    devtool: "source-map",
    target: 'electron'
}
