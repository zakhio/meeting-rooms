import React from 'react';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faBeer } from '@fortawesome/free-solid-svg-icons'

function Footer(props: {}) {
    return (
        <div className="footer">
            <div className="container">
                <div className="row justify-content-center">
                    <div className="col-auto">
                        Research project by <a href="https://zakh.io">zakh.io</a> <FontAwesomeIcon icon={faBeer} />
                    </div>
                </div>
            </div>
        </div>
    )
}

export default Footer;