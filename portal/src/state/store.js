
import thunk from 'redux-thunk';
import { createStore, combineReducers, applyMiddleware, compose } from "redux";

import authReducer from "~/authentication/state";
import serviceReducer from "~/service/state";
import toastReducer from "~/toast/state";

const rootReducer = combineReducers({
  auth: authReducer,
  service: serviceReducer,
  toast: toastReducer,
})

const initStore = () => createStore(
  rootReducer,
  compose(
    applyMiddleware(thunk),
    window.__REDUX_DEVTOOLS_EXTENSION__ ? window.__REDUX_DEVTOOLS_EXTENSION__() : f => f,
  ),
);

export default initStore;
