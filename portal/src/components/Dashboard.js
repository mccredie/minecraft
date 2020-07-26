
import React, { useEffect } from "react";

import ServerStatus from "~/components/ServerStatus";

import "./Dashboard.css";

const Dashboard = ({
    setServerActiveStatus,
    refreshServerStatus,
    serviceState,
    accessDenied,
    statusError
}) => {
    useEffect(() => {
        refreshServerStatus();
    // eslint-disable-next-line
    }, [serviceState.active]);

    let errorComponent = null;
    let accessDeniedComponent = null;
    if (statusError) {
        errorComponent = <h2>statusError</h2>;
    }
    if (accessDenied) {
        accessDeniedComponent = <h2>You do not have access to see server status</h2>;
    }

    return <div className="Dashboard">
        {errorComponent}
        {accessDeniedComponent}
        <div className="Dashboard-status">
            <div className="Dashboard-statusHeader-border">
                <div className="Dashboard-statusHeader">
                    <div className="Dashboard-statusHeader-col">Name</div>
                    <div className="Dashboard-statusHeader-col">Enable</div>
                    <div className="Dashboard-statusHeader-col">Status</div>
                    <div className="Dashboard-statusHeader-col">Domain</div>
                </div>
            </div>
            <ServerStatus name="survival"
                {...serviceState}
                onClickRefresh={refreshServerStatus}
                onChangeActive={setServerActiveStatus} />
        </div>
    </div>
};

export default Dashboard;
