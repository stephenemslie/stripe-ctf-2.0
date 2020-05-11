import CodeView from "./codeview.jsx";
import React from "react";
import ReactDOM from "react-dom";

export const initCodeView = (props, element) => {
  ReactDOM.render(React.createElement(CodeView, props, null), element);
};
