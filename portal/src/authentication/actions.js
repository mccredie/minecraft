
export const setAuthenticated = (payload) => ({
    type: "AUTHENTICATED/SET",
    payload,
});

export const setAccessToken = (payload) => ({
    type: "ACCESS_TOKEN/SET",
    payload,
});

export const setLoading = (payload) => ({
    type: "LOADING/SET",
    payload,
});
