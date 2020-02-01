
import React from "react";
import classNames from "classnames";

import "./Slider.css"

const Slider = ({active, onClick}) => {
    return <div className={classNames("Slider", {active})} onClick={onClick}>
        <div className="Slider-switch"></div>
    </div>;
};

export default Slider;
