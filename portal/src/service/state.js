
import { combineReducers } from 'redux';
import { makeSetReducer } from '~/utils/state';

const reduce = combineReducers({
    state: (state={ canToggle: false, state: "Unknown", active: false }, action) => {
        if (action.type === "SERVER_STATUS/SET") {
            const {state: status, active} = action.payload;
            let canToggle = false;
            if (active && status === "InService") {
                canToggle = true;
            }
            if (!active && (status === null || status === "Terminated")) {
                canToggle = true;
            }

            return {
                state: status,
                active,
                canToggle
            }
        }
        return state;
    },
    accessDenied: makeSetReducer("ACCESS_DENIED/SET", false),
    statusError: makeSetReducer("SERVER_STATUS_ERROR/SET", null),
});

export default reduce;
