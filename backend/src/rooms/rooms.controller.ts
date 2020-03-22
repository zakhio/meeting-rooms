import { Controller, Query, Get } from '@nestjs/common';
import { RoomsService } from './rooms.service';
import { Room } from './interfaces/room.interface';

@Controller('v1/rooms')
export class RoomsController {
    constructor(private roomsService: RoomsService) { }

    /**
     * Returns a list of rooms which are available for booking with their
     * status in 20 mins.
     * 
     * @param accessToken user's access token
     */
    @Get('available')
    async getAvailableRooms(@Query('accessToken') accessToken: string, @Query('minutes') minutes: number): Promise<Room[]> {
        const rooms = await this.roomsService.getFreeRooms(accessToken, minutes);
        return rooms;
    }
}
