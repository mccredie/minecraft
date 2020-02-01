
export const makeSetReducer = (actionType, defaultValue) => (state, action) => {
    if (typeof state === 'undefined') {
        state = defaultValue;
    }
    switch(action.type){
        case actionType:
            return action.payload;
        default:
            return state
    }
}
