import { GoogleLoginResponse } from "react-google-login";
import { AnyAction, Reducer } from "redux";
import * as ActionTypes from "./ActionTypes";

export type User = {
    imageUrl: string;
    email: string;
    name: string;
    givenName: string;
    familyName: string;
}

export type UserState = {
    isLoading: boolean;
    errMess: string | null;
    user: User | null;
    accessToken: string | null;
}

export const UserReducer: Reducer<UserState, AnyAction> = (
    state: UserState = {
        isLoading: false,
        errMess: null,
        user: null,
        accessToken: null
    }, action: AnyAction): UserState => {
    switch (action.type) {
        case ActionTypes.USER_LOGIN_SUCCESS:
            let response = (action.payload as GoogleLoginResponse);
            return {
                ...state,
                isLoading: false,
                errMess: null,
                user: response.profileObj,
                accessToken: response.accessToken
            };
        case ActionTypes.USER_LOGOUT_SUCCESS:
            return {
                ...state,
                isLoading: false,
                errMess: null,
                user: null,
                accessToken: null

            };
        default:
            return state;
    }
};