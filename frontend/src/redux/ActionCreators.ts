import { GoogleLoginResponse, GoogleLoginResponseOffline } from 'react-google-login';
import { AnyAction, Dispatch } from 'redux';
import { baseUrl } from "../shared/baseUrl";
import * as ActionTypes from './ActionTypes';

export const fetchRooms = (dispatch: Dispatch) => async (accessToken: string) => {
    dispatch(roomsLoading());

    return fetch(baseUrl + 'v1/rooms/available?accessToken=' + accessToken + "&minutes=60")
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
    if (loginResponse.accessToken !== undefined) {
        dispatch(userLoginSuccess(loginResponse));
        fetchRooms(dispatch)(loginResponse.accessToken);
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