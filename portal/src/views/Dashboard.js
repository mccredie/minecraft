import { connect } from "react-redux";

import DashboardComponent from  "~/components/Dashboard";
import { setServerActiveStatus, refreshServerStatus } from "~/service/operations";
import { getServiceState, getAccessDenied, getStatusError } from "~/service/selectors";


const mapStateToProps = (state) => ({
    serviceState: getServiceState(state),
    accessDenied: getAccessDenied(state),
    statusError: getStatusError(state),
})

const mapDispatchToProps = {
    setServerActiveStatus,
    refreshServerStatus,
};

export default connect(mapStateToProps, mapDispatchToProps)(DashboardComponent)
