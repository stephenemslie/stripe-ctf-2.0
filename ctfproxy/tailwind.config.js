const breadcrumbs = require("./assets/tailwind-breadcrumbs.js");

module.exports = {
  purge: ["./assets/*.jsx", "./templates/**/*.html"],
  plugins: [breadcrumbs],
  theme: {
    extend: {
      colors: {
        "prism-bg": "#2d3748"
      }
    }
  },
  variants: {}
};
