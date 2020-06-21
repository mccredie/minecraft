import React, { useEffect }  from 'react';


import NavBar from '~/views/NavBar';
import Dashboard from '~/views/Dashboard';
import Toast from '~/views/Toast';


const App = ({ isLoading, login }) => {
  useEffect(() => {
    login();
    // eslint-disable-next-line
  }, []);
  if (isLoading) {
      return (<div>
          <span>Loading...</span>
      </div>);
  }
  else {
    return (
        <div className="App">
          <header className="App-header">
              <NavBar />
          </header>
          <Dashboard />
          <Toast />
        </div>
    )
  }
};

export default App;
