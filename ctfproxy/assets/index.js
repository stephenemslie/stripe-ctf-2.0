import CodeView from "./codeview.jsx";
import React from "react";
import ReactDOM from "react-dom";
import stylesCSS from "./styles.css";
import prismCSS from "./prism-tailwind.css";

export const initCodeView = (props, element) => {
  ReactDOM.render(React.createElement(CodeView, props, null), element);
};
