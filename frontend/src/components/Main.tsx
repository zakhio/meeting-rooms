import React, { Component } from 'react';
import { GoogleLoginResponse, GoogleLoginResponseOffline } from 'react-google-login';
import { connect, RootStateOrAny } from "react-redux";
import { Redirect, Route, Switch, withRouter } from 'react-router-dom';
import { AnyAction, Dispatch } from 'redux';
import { fetchRooms, userSignedIn, userSignedOut } from "../redux/ActionCreators";
import { RoomsState } from '../redux/rooms';
import { UserState } from '../redux/user';
import Footer from "./Footer";
import Header from "./Header";
import Home from "./Home";
import Rooms from "./Rooms";

type MainProps = {
    rooms: RoomsState;
    user: UserState;
    fetchRooms: (accessToken:string) => Promise<AnyAction>;
    userSignIn: (response: GoogleLoginResponse | GoogleLoginResponseOffline) => void;
    userSignOut: () => void;
}

const mapStateToProps = (state: RootStateOrAny) => {
    return {
        rooms: state.rooms,
        user: state.user
    }
};

const mapDispatchToProps = (dispatch: Dispatch) => ({
    fetchRooms: fetchRooms(dispatch),
    userSignIn: userSignedIn(dispatch),
    userSignOut: userSignedOut(dispatch),
});

class Main extends Component<MainProps, {}> {

    componentDidMount() {
        // this.props.fetchRooms();
    }

    render() {
        const HomePage = () => {
            return (
                <Home/>
            );
        };

        return (
            <div>
                <Header
                    userSignedIn={this.props.userSignIn}
                    userSignedOut={this.props.userSignOut}
                    user={this.props.user.user} />
                <Switch>
                    <Route path="/home" component={HomePage} />
                    <Route exact path="/rooms" component={() => <Rooms rooms={this.props.rooms} />} />
                    <Redirect to="/home" />
                </Switch>
                <Footer />
            </div>
        )
    };
}

export default withRouter(connect(mapStateToProps, mapDispatchToProps)(Main));
