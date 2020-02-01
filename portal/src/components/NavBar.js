
import React, {useState} from 'react';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faBars } from '@fortawesome/free-solid-svg-icons'

import logo from './logo.png'
import './NavBar.css'

const NavBar = ({logout, title}) => {
  const [menuOpen, setMenuOpen] = useState(false)

  return (
      <nav className='NavBar'>
        <span className='NavBar-toggle'>
            <FontAwesomeIcon onClick={() => setMenuOpen(!menuOpen)} icon={faBars}/>
        </span>
        <span className='NavBar-logo'> <img src={logo} alt={title} />{title}</span>
        <ul className={ menuOpen ? 'NavBar-main active' : 'NavBar-main' }>
            <li>
              <button className='NavBar-links'  onClick={logout}>logout</button>
            </li>
        </ul>
      </nav>
  );

};

export default NavBar;
