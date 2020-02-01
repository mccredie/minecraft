
import React from "react";
import classNames from "classnames";

import "./StateIndicator.css";

const StateLight = ({active, color="red", children=null}) => {
    return <div className={classNames("StateLight", color, {active})}>
        <div className="StateLight-bulb"></div>
        <div className="StateLight-overlay">
            <div className="StateLight-content">{children}</div>
        </div>
    </div>
};

const states = [
  ["Pending", "yellow"],
  ["InService", "green"],
  ["Terminating", "yellow"],
  ["Terminated", "red"],
];

const StateIndicator = ({state}) => (
    <ul className="StateIndicator">
        {
            states.map(([stateName, color]) => (
                <li key={stateName}><StateLight active={state === stateName} color={color}>{stateName}</StateLight></li>
            ))
        }
    </ul>
);


export default StateIndicator;
