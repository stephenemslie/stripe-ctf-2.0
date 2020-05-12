const path = require("path");

module.exports = {
  entry: "./assets/index.js",
  output: {
    path: path.resolve(__dirname, "static"),
    filename: "bundle.js",
    library: "EntryPoint"
  },
  module: {
    rules: [
      {
        test: /\.jsx?$/,
        include: path.resolve(__dirname, "assets"),
        exclude: /node_modules/,
        use: [
          {
            loader: "babel-loader",
            options: {
              presets: ["@babel/preset-react"]
            }
          }
        ]
      },
      {
        test: /\.css$/,
        include: path.resolve(__dirname, "assets"),
        exclude: /node_modules/,
        use: ["style-loader", "css-loader", "postcss-loader"]
      },
      {
        test: /\.(woff|woff2|svg)$/,
        use: ["url-loader"],
        include: path.resolve(__dirname, "assets"),
        exclude: /node_modules/
      }
    ]
  },
  devtool: "source-map"
};
