import { Controller, Query, Get } from '@nestjs/common';
import { RoomsService } from './rooms.service';
import { Room } from './interfaces/room.interface';

@Controller('v1/rooms')
export class RoomsController {
    constructor(private roomsService: RoomsService) { }

    // Fetch all events
    @Get('available')
    async getEvents(@Query('accessToken') accessToken: string): Promise<Room[]> {
        const rooms = await this.roomsService.getFreeRooms(accessToken, 20);
        return rooms;
    }
}
