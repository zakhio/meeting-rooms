import React, { Component } from 'react';
import { GoogleLoginResponse, GoogleLoginResponseOffline } from "react-google-login";
import { NavLink } from "react-router-dom";
import { Collapse, Nav, Navbar, NavbarBrand, NavbarToggler, NavItem } from 'reactstrap';
import { User } from '../redux/user';
import { Login } from './Login';

type HeaderProps = {
    userSignedIn: (response: GoogleLoginResponse | GoogleLoginResponseOffline) => void;
    userSignedOut: () => void;
    user: User | null;
}

class Header extends Component<HeaderProps, { isNavOpen: boolean, isModalOpen: boolean }> {
    constructor(props: HeaderProps) {
        super(props);

        this.state = {
            isNavOpen: false,
            isModalOpen: false
        }
    }

    toggleNav = () => {
        this.setState({
            isNavOpen: !this.state.isNavOpen
        });
    };

    toggleModal = () => {
        this.setState({
            isModalOpen: !this.state.isModalOpen
        });
    };

    handleFailure = (error: any): void => {
        console.log(error);
    };

    handleLoading = (): void => {
        console.log("Loading");
    };

    render() {
        return (
            <React.Fragment>
                <Navbar dark expand="md">
                    <div className="container">
                        <NavbarToggler onClick={this.toggleNav} />
                        <NavbarBrand className="mr-auto" href="/">
                            <img src="logo192.png" height="30" width="30"
                                alt="Meeting Room Finder" />
                        </NavbarBrand>
                        <Collapse isOpen={this.state.isNavOpen} navbar>
                            <Nav navbar>
                                <NavItem>
                                    <NavLink className="nav-link" to="/home">
                                        Home
                                    </NavLink>
                                </NavItem>
                            </Nav>
                            <Nav className="ml-auto" navbar>
                                <NavItem>
                                    <Login
                                        userSignedIn={this.props.userSignedIn}
                                        userSignedOut={this.props.userSignedOut}
                                        user={this.props.user}
                                    />
                                </NavItem>
                            </Nav>
                        </Collapse>
                    </div>
                </Navbar>
            </React.Fragment>
        );
    }
}

export default Header;