import React from "react";
import { connect } from "react-redux";

import { TITLE } from "~/config";
import NavBarComponent from  "~/components/NavBar";
import { logout } from "~/authentication/operations";


const NavBar = ({ logout }) => {
  return (
      <NavBarComponent title={TITLE} logout={logout} />
  );
};

const mapDispatchToProps = {
    logout,
}


export default connect(null, mapDispatchToProps)(NavBar)
