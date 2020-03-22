import React from 'react';
import { ListGroup, ListGroupItem, ListGroupItemHeading, ListGroupItemText } from 'reactstrap';
import { Room, RoomsState } from '../redux/rooms';
import { Loading } from "./Loading";
import moment from "moment";

function RenderRoomItem({ room }: { room: Room }) {
    let statusText = "Free";
    let colorClass = "text-success";
    const now = moment();

    if (room.occupation.until) {
        statusText = `Occupied for ${room.occupation.until.diff(now, "m")} min`;
        colorClass = "text-danger";
    } else if (room.occupation.next) {
        statusText = `Free for ${room.occupation.next.diff(now, "m")} min`;
        if (room.freeMinutes > 0 && room.freeMinutes < 5) {
            colorClass = "text-warning";
        }
    }

    return (
        <ListGroupItem key={room.id}>
            <ListGroupItemHeading>{room.name}&nbsp;<span className={colorClass}>{statusText}</span></ListGroupItemHeading>
            <ListGroupItemText style={{ marginBottom: 0 }}>Floor: {room.floor}. Room capacity: {room.capacity}.</ListGroupItemText>
        </ListGroupItem>
    )
}

const Rooms = (props: { rooms: RoomsState }) => {
    const rooms: Room[] = props.rooms.rooms.slice();
    rooms.sort((r1, r2) => r1.freeMinutes - r2.freeMinutes).reverse();

    const roomItems = rooms.map((room) => {
        return (
            <RenderRoomItem room={room} />
        )
    });

    if (props.rooms.isLoading) {
        return (
            <div className="container">
                <div className="row">
                    <Loading />
                </div>
            </div>
        );
    } else if (props.rooms.errMess) {
        return (
            <div className="container">
                <div className="row">
                    <h4>{props.rooms.errMess}</h4>
                </div>
            </div>
        );
    } else {
        return (
            <div className="container">
                <div className="row">
                    <div className="col-12">
                        <h3>Free Meeting Rooms</h3>
                        <hr />
                    </div>
                </div>
                <ListGroup>
                    {roomItems}
                </ListGroup>
            </div>
        );
    }
};


export default Rooms;