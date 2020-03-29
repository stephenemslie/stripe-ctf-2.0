const breadcrumbs = require("./tailwind-breadcrumbs.js");

module.exports = {
  plugins: [breadcrumbs],
  theme: {
    extend: {
      colors: {
        dark: "#34294f"
      }
    }
  },
  variants: {}
};
