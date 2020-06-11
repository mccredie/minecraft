
export default (state={text: "", show: false}, action) => {
    switch(action.type) {
        case "CREATE_TOAST":
            return {
                text: action.text,
                show: false
            };
        case "SHOW_TOAST":
            return {...state, show: true};
        case "HIDE_TOAST":
            return {...state, show: false};
        default:
            return state;
    }
}
