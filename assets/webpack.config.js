const path = require("path");
const Webpack = require("webpack");
const ExtractTextPlugin = require("mini-css-extract-plugin");
const CopyWebpackPlugin = require("copy-webpack-plugin");
const OptimizeCSSAssetsPlugin = require("optimize-css-assets-webpack-plugin");
const UglifyJsPlugin = require("uglifyjs-webpack-plugin");
const config = require("./package");

const ENV = process.env.MIX_ENV || "dev";
const IS_PROD = ENV === "prod";
const OUTPUT_PATH = path.resolve(__dirname, "..", "priv", "static");

const ExtractCSS = new ExtractTextPlugin({
  filename: IS_PROD ? "[name].[hash].css" : "[name].css",
  chunkFilename: IS_PROD ? "[id].[hash].css" : "[id].css"
});

var PLUGINS = [
  ExtractCSS,
  new Webpack.DefinePlugin({
    APP_NAME: JSON.stringify(config.app_name),
    VERSION: JSON.stringify(config.version),
    ENV: JSON.stringify(ENV)
  }),
  new CopyWebpackPlugin([
    {
      context: "./static",
      from: "**/*",
      to: "."
    }
    // maybe later; let's try to not use font-awesome
    // {
    //   context: "./node_modules/font-awesome/fonts",
    //   from: "*",
    //   to: "./fonts"
    // }
  ])
];

module.exports = function(env = {}) {
  return {
    target: "web",
    entry: {
      app: ["./js/app.js", "./css/app.scss"],
      stats: "./js/stats.js"
    },

    output: {
      filename: "js/[name].js",
      path: OUTPUT_PATH
    },

    devtool: IS_PROD ? false : "source-map",

    resolve: {
      modules: ["node_modules", __dirname + "/js"]
    },

    module: {
      rules: [
        {
          test: /\.js$/,
          exclude: /(node_modules|bower_components)/,
          loader: "babel-loader"
        },
        {
          test: /\.(sa|sc|c)ss$/,
          use: [
            {
              loader: IS_PROD ? ExtractTextPlugin.loader : "style-loader",
              options: { sourceMap: IS_PROD ? false : true }
            },
            { loader: "css-loader", options: { sourceMap: IS_PROD ? false : true } },
            { loader: "postcss-loader", options: { sourceMap: IS_PROD ? false : true } },
            { loader: "sass-loader", options: { sourceMap: IS_PROD ? false : true } }
          ]
        },
        {
          test: /\.(eot|svg|ttf|woff|woff2)$/,
          loader: "url-loader"
        }
      ]
    },

    optimization: {
      minimizer: [
        new UglifyJsPlugin({
          cache: true,
          parallel: true,
          sourceMap: true // set to true if you want JS source maps
        }),
        new OptimizeCSSAssetsPlugin({})
      ]
    },

    plugins: PLUGINS,
    //optimization: { minimize: IS_PROD },
    stats: { colors: true },
    mode: IS_PROD ? "production" : "development"
  };
};
