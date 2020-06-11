
export const createToast = (text) => ({
    type: "CREATE_TOAST",
    text
});

export const showToast = () => ({
    type: "SHOW_TOAST"
});

export const hideToast = () => ({
    type: "HIDE_TOAST"
});

export const dismissToast = () => ({
    type: "DISMISS_TOAST"
})
