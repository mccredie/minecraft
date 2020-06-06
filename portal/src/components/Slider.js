
import React from "react";

import "./Slider.css"

const Slider = ({checked, disabled, onChange}) => (
    <label className="Slider" >
      <input type="checkbox" checked={checked} disabled={disabled} onChange={(e) => onChange(e.target.value)} />
      <span className="Slider-switch"></span>
    </label>
);

export default Slider;
