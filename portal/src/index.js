import React from "react";
import ReactDOM from "react-dom";

import App from "~/views/App";
import initStore from "~/state/store";
import { Provider } from "react-redux";
import * as serviceWorker from "~/serviceWorker";
import { AUTH_DOMAIN, CLIENT_ID, AUDIENCE } from "~/config";

import { initAuth } from "./authentication/operations";

import history from "./utils/history";

import './index.css';

// A function that routes the user to the right place
// after login
const onRedirectCallback = appState => {
  history.push(
    appState && appState.targetUrl
      ? appState.targetUrl
      : window.location.pathname
  );
};

const store = initStore();
initAuth({
  domain: AUTH_DOMAIN,
  client_id: CLIENT_ID,
  audience: AUDIENCE,
  redirect_uri: window.location.origin,
  onRedirectCallback: onRedirectCallback,
})

ReactDOM.render(
  <Provider store={store}>
    <App />
  </Provider>,
  document.getElementById("root")
);

serviceWorker.unregister();
