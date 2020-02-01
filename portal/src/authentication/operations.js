
import createAuth0Client from "@auth0/auth0-spa-js";

import { setLoading, setAccessToken } from "./actions";


let resolveAuthClient;
let rejectAuthClient;
let authClientPromise = new Promise((resolve, reject) => {
    resolveAuthClient = resolve;
    rejectAuthClient = reject;
})

export const initAuth = async (initOptions) => {
    try {
        resolveAuthClient(await createAuth0Client(initOptions));
    } catch(error) {
        rejectAuthClient(error);
    }
}

const onRedirectCallback = () =>
  window.history.replaceState({}, document.title, window.location.pathname);

export const login = () => async (dispatch) => {
  const auth0Client = await authClientPromise;

  if (window.location.search.includes("code=") &&
      window.location.search.includes("state=")) {
    const { appState } = await auth0Client.handleRedirectCallback();
    onRedirectCallback(appState);
  }

  const isAuthenticated = await auth0Client.isAuthenticated();
  if (!isAuthenticated) {
      await auth0Client.loginWithRedirect();
  }

  dispatch(setAccessToken(await auth0Client.getTokenSilently()));
  dispatch(setLoading(false));
}

export const logout = () => async (dispatch) => {
  const auth0Client = await authClientPromise;

  return await auth0Client.logout();
};
