import { GoogleLoginResponse, GoogleLoginResponseOffline } from 'react-google-login';
import { AnyAction, Dispatch } from 'redux';
import { baseUrl } from "../shared/baseUrl";
import * as ActionTypes from './ActionTypes';

export const fetchRooms = (dispatch: Dispatch) => async (accessToken: string) => {
    dispatch(roomsLoading());

    const token = localStorage.token;

    return fetch(baseUrl + 'v1/rooms/available?&minutes=60',
        {
            method: "GET",
            headers: {
                'Accept': 'application/json',
                'Authorization': `Bearer ${token}`
            }
        })
        .then(response => {
            if (response.ok) {
                return response;
            } else {
                let error = new Error('Error ' + response.status + ': ' + response.statusText);
                throw error;
            }
        },
            error => {
                let errmess = new Error(error.message);
                throw errmess;
            })
        .then(response => response.json())
        .then(rooms => dispatch(addRooms(rooms)))
        .catch(error => dispatch(roomsFailed(error.message)));
};

export const roomsLoading = (): AnyAction => ({
    type: ActionTypes.ROOMS_LOADING
});

export const roomsFailed = (errmess: string): AnyAction => ({
    type: ActionTypes.ROOMS_FAILED,
    payload: errmess
});

export const addRooms = (rooms: []): AnyAction => ({
    type: ActionTypes.ADD_ROOMS,
    payload: rooms
});

export const userSignedIn = (dispatch: Dispatch) => (response: GoogleLoginResponse | GoogleLoginResponseOffline) => {
    let loginResponse = (response as GoogleLoginResponse);
    const accessToken = loginResponse.accessToken;
    if (accessToken !== undefined) {
        localStorage.setItem("token", accessToken);
        dispatch(userLoginSuccess(loginResponse));
        fetchRooms(dispatch)(accessToken);
    }
};

export const userLoginSuccess = (response: GoogleLoginResponse): AnyAction => ({
    type: ActionTypes.USER_LOGIN_SUCCESS,
    payload: response
});

export const userSignedOut = (dispatch: Dispatch) => () => {
    dispatch(userLogoutSuccess());
};

export const userLogoutSuccess = (): AnyAction => ({
    type: ActionTypes.USER_LOGOUT_SUCCESS
});