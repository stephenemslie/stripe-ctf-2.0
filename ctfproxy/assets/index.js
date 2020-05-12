import CodeView from "./codeview.jsx";
import React from "react";
import ReactDOM from "react-dom";
import stylesCSS from "./styles.css";
import prismCSS from "./prism-tailwind.css";
import "prismjs";
import "prismjs/components/prism-ruby";
import "prismjs/components/prism-python";
import "prismjs/components/prism-markup-templating";
import "prismjs/components/prism-clike";
import "prismjs/components/prism-php";

export const initCodeView = (props, element) => {
  ReactDOM.render(React.createElement(CodeView, props, null), element);
};
