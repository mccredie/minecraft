import React from "react";
import Slider from "~/components/Slider";
import StateIndicator from "~/components/StateIndicator";

const ServerStatus = ({active=false, state="terminated", onChangeActive}) => (
    <div>
        <Slider active={active} onClick={() => onChangeActive(!active)} />
        <StateIndicator state={state} />
    </div>
);

export default ServerStatus;
