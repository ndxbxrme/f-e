var path = require("path");
const HtmlWebpackPlugin = require("html-webpack-plugin");

module.exports = {
    mode: "development",
    entry: "./src/index.coffee",
    output: {
        path: path.join(__dirname, "dist"),
        publicPath: "",
        filename: "[name].[contenthash].js"
    },
    devServer: {
      contentBase: path.join(__dirname, "dist"),
      compress: true,
      historyApiFallback: true,
      port: 9000
    },
    plugins: [
      new HtmlWebpackPlugin({
        template: path.join(__dirname, "src/index.pug")
      })
    ],
    devtool: 'source-map',
    module: {
        rules: [
            {
                test: /\.coffee$/,
                exclude: /node_modules/,
                use: {
                  loader: "coffee-loader",
                  options: {
                    sourceMap: true,
                    presets: ["@babel/env"]
                  }
                }
            },
            {
                test: /\.styl$/,
                use: [
                    "style-loader",
                    "css-loader",
                    "stylus-loader"
                ]
            },
            {
                test: /\.pug$/,
                use: "pug-loader"
            },
            {
              test: /\.(gif|png|jpe?g|svg)$/i,
              use: [
                'file-loader',
                {
                  loader: 'image-webpack-loader',
                  options: {
                    disable: true
                  },
                },
              ],
            }
        ]
    }
}