import React from "react";
import Slider from "~/components/Slider";
import StateIndicator from "~/components/StateIndicator";

const ServerStatus = ({active=false, state="terminated", onChangeActive}) => (
    <div>
        <Slider checked={active} onChange={() => onChangeActive(!active)}/>
        <StateIndicator state={state} />
        <div>{state}</div>
    </div>
);

export default ServerStatus;
