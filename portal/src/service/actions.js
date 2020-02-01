
export const setServiceState = (payload) => ({
    type: "SERVER_STATUS/SET",
    payload,
});

export const setAccessDenied = (payload) => ({
    type: "ACCESS_DENIED/SET",
    payload,
});

export const setStatusError = (payload) => ({
    type: "SERVER_STATUS_ERROR/SET",
    payload,
});
