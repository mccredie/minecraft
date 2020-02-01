
import { SERVICE_URL } from "~/config";

import { setAccessDenied, setStatusError, setServiceState } from "~/service/actions";
import { getAccessToken } from "~/authentication/selectors";

const fetchServerStatus = (root_url, accessToken) => (
  fetch(`${root_url}/servers/survival/status`, {
    cache: 'no-cache', // *default, no-cache, reload, force-cache, only-if-cached
    headers: {
      'Authorization': `Bearer ${accessToken}`
    },
    redirect: 'follow', // manual, *follow, error
  })
);

export const setServerActiveStatus = (active) => async (dispatch, getState) => {
  const accessToken = getAccessToken(getState());
  const resp = await fetch(`${SERVICE_URL}/servers/survival/status`, {
    method: 'PUT',
    cache: 'no-cache', // *default, no-cache, reload, force-cache, only-if-cached
    headers: {
      'Authorization': `Bearer ${accessToken}`
    },
    redirect: 'follow', // manual, *follow, error
    body: JSON.stringify({active}),
  })

  dispatch(setServiceState(await resp.json()));
};


export const refreshServerStatus = () => async (dispatch, getState) => {
  const accessToken = getAccessToken(getState());
  try {
    const resp = await fetchServerStatus(SERVICE_URL, accessToken);
    if (resp.status ===  401 || resp.status === 403) {
      dispatch(setAccessDenied(true));
      dispatch(setStatusError(null));
    }
    else {
      dispatch(setServiceState(await resp.json()));
      dispatch(setAccessDenied(false));
      dispatch(setStatusError(null));
    }
  } catch (error) {
    console.error(error);
    dispatch(setStatusError("Failure fetching status"));
  }
};
