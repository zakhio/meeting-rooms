import * as ActionTypes from "./ActionTypes";
import { AnyAction, Reducer } from "redux";
import moment, { Moment } from "moment";
import { DateRange } from "moment-range";


export type Room = {
    readonly id: string;
    readonly name: string;
    readonly email: string;
    readonly floor: string;
    readonly capacity: number;
    readonly freeMinutes: number;
    readonly occupation: {
        until?: Moment;
        next?: Moment;
    };
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
            const payload: any[] = action.payload;
            const rooms: Room[] = payload.map((room): Room => {
                let budget = 60;
                let occupation: {
                    until?: Moment;
                    next?: Moment;
                } = {};

                // compute freeMinutes and occupation for the room
                if (room.busy && room.busy.length) {
                    const now = moment();

                    const busy: { start: string, end: string }[] = room.busy;
                    busy.sort((a, b) => a.start.localeCompare(b.start));

                    let meetingRange;
                    let nextMeeting;

                    for (let i = 0; i < busy.length; i++) {
                        if (!meetingRange) {
                            if (moment(busy[i].end).isAfter(now)) {
                                meetingRange = new DateRange(moment(busy[i].start), moment(busy[i].end))
                            }
                            continue;
                        }

                        let r = new DateRange(moment(busy[i].start), moment(busy[i].end));
                        if (meetingRange.adjacent(r)) {
                            meetingRange.add(r, { adjacent: true });
                        } else {
                            nextMeeting = r;

                            // Can break as no more consecutives meetings
                            break;
                        }
                    }

                    if (meetingRange?.start.isBefore(now)) {
                        budget = now.diff(meetingRange.end, "m");
                        occupation.until = meetingRange.end;
                        occupation.next = nextMeeting?.start;
                    } else if (meetingRange) {
                        budget = meetingRange.start.diff(now, "m");
                        occupation.next = meetingRange.start;
                    }
                }

                return {
                    id: room.id,
                    name: room.name,
                    email: room.email,
                    floor: room.floor,
                    capacity: room.capacity,
                    freeMinutes: budget,
                    occupation: occupation
                };
            });

            return {
                ...state,
                isLoading: false,
                errMess: null,
                rooms: rooms
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