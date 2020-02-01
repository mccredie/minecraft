
export const getService = (state) => state.service;

export const getServiceState = (state) => getService(state).state;

export const getAccessDenied = (state) => getService(state).accessDenied;

export const getStatusError = (state) => getService(state).statusError;
