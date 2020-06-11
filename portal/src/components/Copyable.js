
import React from 'react';

import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faCopy } from '@fortawesome/free-solid-svg-icons'
import copy from 'copy-to-clipboard';

import "./Copyable.css"

export default ({children, onCopy}) => (
    <span className="Copyable">{children} <FontAwesomeIcon onClick={() => { copy(children); onCopy();}} icon={faCopy} /></span>
);
