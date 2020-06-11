import React from "react";

import Slider from "~/components/Slider";
import Copyable from "~/views/Copyable";

import "./ServerStatus.css";

const ServerStatus = ({name, domain, canToggle, active=false, state=undefined, onChangeActive, showToast}) => (
    <div className="ServerStatus">
        <div className="ServerStatus-col">
            {name}
        </div>
        <div className="ServerStatus-col">
            <Slider disabled={!canToggle} checked={active} onChange={() => onChangeActive(!active)}/>
        </div>
        <div className="ServerStatus-col">
            {state || "Off"}
        </div>
        <div className="ServerStatus-col">
            <Copyable>{domain}</Copyable>
        </div>
    </div>
);

export default ServerStatus;
