import React from "react";

import classNames from "classnames";

import "./Toast.css";

export default ({text, show}) => (
  <div className="Toast-wrapper" >
      <div className={classNames("Toast", {show})}>{text}</div>
  </div>
)
