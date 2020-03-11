const plugin = require("tailwindcss/plugin");

module.exports = {
  plugins: [
    plugin(function({ addUtilities, addComponents, theme }) {
      addComponents({
        ".breadcrumb": {
          overflow: "hidden",
          li: {
            a: {
              position: "relative",
              display: "block",
              marginLeft: "45px",
              textAlign: "center",
              "&::after": {
                content: '""',
                width: "0",
                height: "0",
                borderTop: "30px solid transparent",
                borderBottom: "30px solid transparent",
                borderLeftWidth: "30px",
                borderLeftStyle: "solid",
                position: "absolute",
                top: "50%",
                marginTop: "-30px",
                left: "100%",
                zIndex: "2"
              },
              "&::before": {
                content: '""',
                width: "0",
                height: "0",
                borderTop: "30px solid transparent",
                borderBottom: "30px solid transparent",
                borderLeftWidth: "30px",
                borderLeftStyle: "solid",
                borderLeftColor: "white",
                position: "absolute",
                top: "50%",
                marginTop: "-30px",
                marginLeft: "1px",
                left: "100%",
                zIndex: "1"
              }
            },
            "&:first-child": {
              a: {
                marginLeft: "30px"
              }
            },
            "&:last-child": {
              a: {
                marginRight: "30px",
                "&::after": {
                  border: 0
                },
                "&::before": {
                  border: 0
                }
              }
            }
          }
        }
      });
      const utilities = {};
      Object.entries(theme("colors")).map(([color, shades]) => {
        Object.entries(shades).map(([shade, value]) => {
          utilities[`.breadcrumb-arrow-${color}-${shade} a::after`] = {
            borderLeftColor: value
          };
        });
      });
      addUtilities(utilities, ["hover"]);
    })
  ],
  theme: {
    extend: {
      colors: {
        dark: "#34294f"
      }
    }
  },
  variants: {}
};
