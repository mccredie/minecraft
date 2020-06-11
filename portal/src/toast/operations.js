import {createToast, showToast, hideToast, dismissToast} from "./actions";
import {timeout} from "~/utils/timeout";

export const toast = (text, time) => {
    return async (dispatch) => {
        dispatch(createToast(text));
        await timeout(300);
        dispatch(showToast());
        await timeout(time);
        dispatch(hideToast());
        await timeout(300);
        dispatch(dismissToast());
    }
}
