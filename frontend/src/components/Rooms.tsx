import React from 'react';
import {Breadcrumb, BreadcrumbItem, Card, CardImg, CardImgOverlay, CardTitle} from 'reactstrap';
import {Link} from "react-router-dom";
import {Loading} from "./Loading";
import {baseUrl} from "../shared/baseUrl";
import { RoomsState, Room } from '../redux/rooms';

function RenderRoomItem({room}: {room: Room}) {
    return (
        <Card>
            <Link to={`/menu/${room.id}`}>
                <CardImg width="100%" src={baseUrl + room.image} alt={room.name}/>
                <CardImgOverlay>
                    <CardTitle>{room.name}</CardTitle>
                </CardImgOverlay>
            </Link>
        </Card>
    )
}

const Rooms = (props: {rooms: RoomsState}) => {
    const menu = props.rooms.rooms.map((room) => {
        return (
            <div key={room.id} className="col-12 col-md-5 m-1">
                <RenderRoomItem room={room}/>
            </div>
        )
    });

    if (props.rooms.isLoading) {
        return (
            <div className="container">
                <div className="row">
                    <Loading/>
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
                    <Breadcrumb>
                        <BreadcrumbItem><Link to="/home">Home</Link></BreadcrumbItem>
                        <BreadcrumbItem active>Menu</BreadcrumbItem>
                    </Breadcrumb>
                    <div className="col-12">
                        <h3>Menu</h3>
                        <hr/>
                    </div>
                </div>
                <div className="row">
                    {menu}
                </div>
            </div>
        );
    }
};


export default Rooms;