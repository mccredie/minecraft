import React from "react";

import classNames from "classnames";

import "./Toast.css";

export default ({text, show}) => (
  <div className={classNames("Toast", {show})}>{text}</div>
)
