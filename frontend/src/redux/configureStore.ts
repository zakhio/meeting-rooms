import { applyMiddleware, combineReducers, createStore } from "redux";
import logger from "redux-logger";
import thunk from "redux-thunk";
import { RoomsReducer } from "./rooms";
import { UserReducer } from "./user";

export const ConfigureStore = () => {
    const store = createStore(
        combineReducers({
            rooms: RoomsReducer,
            user: UserReducer
        }),
        applyMiddleware(thunk, logger)
    );

    return store;
};