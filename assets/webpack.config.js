const path = require("path");
const Webpack = require("webpack");
const ExtractTextPlugin = require("mini-css-extract-plugin");
const CopyWebpackPlugin = require("copy-webpack-plugin");
const OptimizeCSSAssetsPlugin = require("optimize-css-assets-webpack-plugin");
const MinifyPlugin = require("babel-minify-webpack-plugin");
const CompressionWebpackPlugin = require("compression-webpack-plugin");
const config = require("./package");

const ENV = process.env.MIX_ENV || "dev";
const OUTPUT_PATH = path.resolve(__dirname, "..", "priv", "static");

module.exports = function(env = {}, argv) {
  const IS_PROD = ENV === "prod";
  const ExtractCSS = new ExtractTextPlugin({
    filename: "css/[name].css",
    chunkFilename: IS_PROD ? "css/[id].[hash].css" : "css/[id].css"
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
      },
      {
        context: "./node_modules/katex/dist/",
        from: "katex.min.css",
        to: "./css"
      },
      {
        context: "./node_modules/katex/dist/fonts",
        from: "*",
        to: "./css/fonts"
      }
      // maybe later; let's try to not use font-awesome
      // {
      //   context: "./node_modules/font-awesome/fonts",
      //   from: "*",
      //   to: "./fonts"
      // }
    ])
  ];

  if (IS_PROD) {
    PLUGINS.push(new CompressionWebpackPlugin());
  }

  return {
    target: "web",
    entry: {
      app: "./js/app.js"
    },

    output: {
      filename: "js/[name].js",
      chunkFilename: "js/[name].[chunkhash].js",
      path: OUTPUT_PATH,
      publicPath: "/"
    },

    devtool: IS_PROD ? false : "source-map",

    resolve: {
      modules: ["node_modules", __dirname + "/js"],
      extensions: ["*", ".js", ".jsx"]
    },

    module: {
      rules: [
        {
          test: /\.jsx?$/,
          exclude: /(node_modules|bower_components)/,
          loader: "babel-loader"
        },
        {
          test: /\.bundle\.js$/,
          use: "bundle-loader"
        },
        {
          test: /\.(sa|sc|c)ss$/,
          use: [
            {
              loader: ExtractTextPlugin.loader,
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
      minimizer: [new MinifyPlugin({}, { cache: true, parallel: true }), new OptimizeCSSAssetsPlugin({})],
      splitChunks: {
        chunks: "async"
      }
    },

    plugins: PLUGINS,
    //optimization: { minimize: IS_PROD },
    stats: { colors: true },
    mode: IS_PROD ? "production" : "development"
  };
};
