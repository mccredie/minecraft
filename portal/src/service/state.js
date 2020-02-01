
import { combineReducers } from 'redux';
import { makeSetReducer } from '~/utils/state';

const reduce = combineReducers({
    state: makeSetReducer("SERVER_STATUS/SET", null),
    accessDenied: makeSetReducer("ACCESS_DENIED/SET", false),
    statusError: makeSetReducer("SERVER_STATUS_ERROR/SET", null),
});

export default reduce;
