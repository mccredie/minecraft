
import { combineReducers } from 'redux';
import { makeSetReducer } from '~/utils/state';


const reduce = combineReducers({
    isAuthenticated: makeSetReducer("AUTHENTICATED/SET", false),
    accessToken: makeSetReducer("ACCESS_TOKEN/SET", null),
    isLoading: makeSetReducer("LOADING/SET", true),
})

export default reduce;
