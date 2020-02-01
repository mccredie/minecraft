
import React, { useEffect } from "react";

import ServerStatus from "~/components/ServerStatus";


const Dashboard = ({
    setServerActiveStatus,
    refreshServerStatus,
    serviceState,
    accessDenied,
    statusError
}) => {
    const handleChangeActiveStatus = (active) => setServerActiveStatus(active);

    useEffect(() => {
        refreshServerStatus();
    // eslint-disable-next-line
    }, []);

    let statusText = "The server is OFF"

    if (statusError) {
        statusText = statusError;
    }
    else if (accessDenied) {
        statusText = "You do not have access to see server status";
    } else if (serviceState && serviceState.active) {
        statusText = "The server is ON";
    }

    return <div>
        <h2>{statusText}</h2>
        <ServerStatus {...serviceState} onChangeActive={handleChangeActiveStatus} />
    </div>
};

export default Dashboard;
