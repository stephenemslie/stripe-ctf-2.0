const breadcrumbs = require("./assets/tailwind-breadcrumbs.js");

module.exports = {
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
