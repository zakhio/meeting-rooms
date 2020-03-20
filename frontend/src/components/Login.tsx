import React, { useState } from 'react';
import { GoogleLogin, GoogleLoginResponse, GoogleLoginResponseOffline, GoogleLogout } from 'react-google-login';
import { Button, Col, Media, Popover, PopoverBody, PopoverHeader, Row } from 'reactstrap';
import { User } from '../redux/user';
import { googleOAuth2Config } from '../shared/googleConfig';

type LoginProps = {
    userSignedIn: (response: GoogleLoginResponse | GoogleLoginResponseOffline) => void;
    userSignedOut: () => void;
    user: User | null;
}

export const Login = (props: LoginProps) => {
    const [popoverOpen, setPopoverOpen] = useState(false);

    const toggle = () => setPopoverOpen(!popoverOpen);

    const handleFailure = (error: any): void => {
        console.log(error);
    }

    const handleLogoutSuccess = (): void => {
        setPopoverOpen(false);
        props.userSignedOut();
    }

    const handleLoginSuccess = (response: GoogleLoginResponse | GoogleLoginResponseOffline): void => {
        props.userSignedIn(response);
    }

    if (props.user != null) {
        return (
            <Row>
                <Col>
                    <Button color="link" id="profileIcon" >
                        <Media object
                            className="rounded-circle"
                            src={props.user.imageUrl}
                            style={{ width: 28, height: 28 }} />
                    </Button>
                    <Popover
                        popperClassName="shadow-sm"
                        placement="bottom"
                        target="profileIcon"
                        isOpen={popoverOpen}
                        toggle={toggle}>
                        <PopoverHeader className="text-center">
                            <Media object
                                className="rounded-circle"
                                src={props.user.imageUrl}
                                style={{ marginBottom: 10, marginTop: 5, width: 80, height: 80 }} />
                            <Media body style={{ paddingLeft: 20, paddingRight: 20, paddingBottom: 5 }}>
                                <Media heading>{props.user.name}</Media>
                                {props.user.email}
                            </Media>
                        </PopoverHeader>
                        <PopoverBody className="text-center">
                            <GoogleLogout
                                clientId={googleOAuth2Config.clientId}
                                onLogoutSuccess={handleLogoutSuccess}
                                buttonText="Sign out from account">
                            </GoogleLogout>
                        </PopoverBody>
                    </Popover>
                </Col>
            </Row>
        );
    } else {
        return (
            <Row>
                <Col>
                    <GoogleLogin
                        clientId={googleOAuth2Config.clientId}
                        scope={googleOAuth2Config.scope}
                        onSuccess={handleLoginSuccess}
                        onFailure={handleFailure}
                        responseType="id_token"
                        isSignedIn
                        theme="dark" />
                </Col>
            </Row>
        );
    }
}