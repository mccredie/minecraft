import { connect } from "react-redux";

import ToastComponent from "~/components/Toast";
import {getToastText, getToastShow} from "~/toast/selectors";


export default connect(
    (state) => ({
        text: getToastText(state),
        show: getToastShow(state)
    })
)(ToastComponent);
