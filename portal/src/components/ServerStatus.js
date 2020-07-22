import React from "react";
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faSpinner } from '@fortawesome/free-solid-svg-icons'

import Slider from "~/components/Slider";
import Copyable from "~/views/Copyable";

import "./ServerStatus.css";

const ServerStatus = ({name, domain, canToggle, active=false, state=undefined, onChangeActive, showToast}) => (
    <div className="ServerStatus">
        <div className="ServerStatus-col">
            {name}
        </div>
        <div className="ServerStatus-col">
            { !canToggle && <><FontAwesomeIcon icon={faSpinner} pulse /> {"  "} </> }
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
