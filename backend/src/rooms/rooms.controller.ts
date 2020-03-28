import { BadRequestException, Controller, Get, ParseIntPipe, Query } from '@nestjs/common';
import { Room } from './interfaces/room.interface';
import { RoomsService } from './rooms.service';

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
    getAvailableRooms(@Query('accessToken') accessToken: string, @Query('minutes', ParseIntPipe) minutes: number): Promise<Room[]> {
        if (minutes <= 0) {
            throw new BadRequestException("Parameter 'minutes' must be a positive number.");
        }

        return this.roomsService.getFreeRooms(accessToken, minutes);
    }
}
