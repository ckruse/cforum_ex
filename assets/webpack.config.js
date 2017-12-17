const path = require("path");
const Webpack = require("webpack");
const ExtractTextPlugin = require("extract-text-webpack-plugin");
const CopyWebpackPlugin = require("copy-webpack-plugin");
const config = require("./package");

const ENV = process.env.MIX_ENV || "dev";
const IS_PROD = ENV === "prod";
const OUTPUT_PATH = path.resolve(__dirname, "..", "priv", "static");

const ExtractCSS = new ExtractTextPlugin({
  filename: "css/[name].css"
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

if (IS_PROD) {
  PLUGINS = PLUGINS.concat([new Webpack.optimize.UglifyJsPlugin({ compress: true })]);
}

module.exports = function(env = {}) {
  return {
    target: "web",
    entry: {
      app: ["./js/app.js", "./css/app.scss"]
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
          test: /\.css$/,
          loader: ExtractCSS.extract({
            use: [
              {
                loader: "css-loader",
                options: { sourceMap: IS_PROD ? false : true }
              },
              {
                loader: "postcss-loader",
                options: { sourceMap: IS_PROD ? false : true }
              }
            ],
            fallback: "style-loader"
          })
        },
        {
          test: /\.scss$/,
          loader: ExtractCSS.extract({
            use: [
              {
                loader: "css-loader",
                options: { sourceMap: IS_PROD ? false : true }
              },
              {
                loader: "postcss-loader",
                options: { sourceMap: IS_PROD ? false : true }
              },
              {
                loader: "sass-loader",
                options: IS_PROD
                  ? {}
                  : {
                      sourceMap: true,
                      outputStyle: "expanded"
                    }
              }
            ],
            fallback: "style-loader"
          })
        },
        {
          test: /\.(eot|svg|ttf|woff|woff2)$/,
          loader: "url-loader"
        }
      ]
    },

    plugins: PLUGINS,

    stats: {
      colors: true
    }
  };
};
