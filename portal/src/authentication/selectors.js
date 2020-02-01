
export const getAuthentication = (state) => state.auth;
export const getAccessToken = (state) => getAuthentication(state).accessToken;
export const getIsLoading = (state) => getAuthentication(state).isLoading;
