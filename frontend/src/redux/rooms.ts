import * as ActionTypes from "./ActionTypes";
import { AnyAction, Reducer } from "redux";

export type Room = {
    id: number;
    name: string;
    description: string;
    image: string;
}

export type RoomsState = {
    isLoading: boolean;
    errMess: string | null;
    rooms: Room[];
}

export const RoomsReducer: Reducer<RoomsState, AnyAction> = (
    state: RoomsState = {
        isLoading: false,
        errMess: null,
        rooms: []
    }, action: AnyAction): RoomsState => {
    switch (action.type) {
        case ActionTypes.ADD_ROOMS:
            return {
                ...state,
                isLoading: false,
                errMess: null,
                rooms: action.payload
            };
        case ActionTypes.ROOMS_LOADING:
            return {
                ...state,
                isLoading: true,
                errMess: null,
                rooms: []
            };
        case ActionTypes.ROOMS_FAILED:
            return {
                ...state,
                isLoading: false,
                errMess: action.payload,
                rooms: []
            };
        default:
            return state;
    }
};