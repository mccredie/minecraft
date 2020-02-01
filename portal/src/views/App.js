
import { connect } from "react-redux";

import AppComponent from "~/components/App.js";
import { getIsLoading, } from "~/authentication/selectors";
import { login } from "~/authentication/operations";


const mapStateToProps = (state) => ({
    isLoading: getIsLoading(state),
})

const mapDispatchToProps = {
    login,
};


export default connect(mapStateToProps, mapDispatchToProps)(AppComponent);
