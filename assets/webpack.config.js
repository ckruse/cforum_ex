const path = require("path");
const Webpack = require("webpack");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const CopyWebpackPlugin = require("copy-webpack-plugin");
const config = require("./package");

const ENV = process.env.MIX_ENV || "dev";
const OUTPUT_PATH = path.resolve(__dirname, "..", "priv", "static");

module.exports = function (env = {}, argv) {
  const IS_PROD = ENV === "prod";

  var PLUGINS = [
    new MiniCssExtractPlugin({
      filename: "css/[name].css",
      chunkFilename: IS_PROD ? "css/[id].[chunkhash].css" : "css/[id].css",
    }),
    new Webpack.DefinePlugin({
      APP_NAME: JSON.stringify(config.app_name),
      VERSION: JSON.stringify(config.version),
      ENV: JSON.stringify(ENV),
    }),
    new CopyWebpackPlugin({
      patterns: [
        {
          context: "./static",
          from: "**/*",
          to: OUTPUT_PATH,
        },
        {
          context: path.resolve(__dirname, "node_modules/leaflet/dist/images"),
          from: path.resolve(__dirname, "node_modules/leaflet/dist/images/*"),
          to: path.resolve(__dirname, "..", "priv/static/images/leaflet/"),
        },
      ],
    }),
  ];

  return {
    target: "web",
    entry: {
      app: "./js/app.js",
    },

    devServer: {
      disableHostCheck: true,
      headers: {
        "Access-Control-Allow-Origin": "*",
      },
    },

    output: {
      filename: "js/[name].js",
      chunkFilename: "js/[name].[chunkhash].js",
      path: OUTPUT_PATH,
      publicPath: "/",
    },

    devtool: IS_PROD ? "source-map" : "eval-cheap-module-source-map",

    resolve: {
      modules: ["node_modules", __dirname + "/js"],
      extensions: ["*", ".js", ".jsx"],
    },

    module: {
      rules: [
        {
          test: /\.jsx?$/,
          exclude: /(node_modules|bower_components)/,
          loader: "babel-loader",
        },
        {
          test: /\.bundle\.js$/,
          use: "bundle-loader",
        },
        {
          test: /\.(sa|sc|c)ss$/,
          use: [
            { loader: MiniCssExtractPlugin.loader },
            { loader: "css-loader", options: { url: false, sourceMap: IS_PROD ? false : true } },
            { loader: "postcss-loader", options: { sourceMap: IS_PROD ? false : true } },
            { loader: "sass-loader", options: { sourceMap: IS_PROD ? false : true } },
          ],
        },
        {
          test: /\.(eot|svg|ttf|woff|woff2)$/,
          loader: "url-loader",
        },
        {
          test: /\.(gif|jpe?g|png)/,
          loader: "file-loader",
        },
      ],
    },

    optimization: {
      minimize: IS_PROD,
      splitChunks: {
        chunks: "async",
      },
    },

    plugins: PLUGINS,
    stats: { colors: true },
    mode: IS_PROD ? "production" : "development",
  };
};
