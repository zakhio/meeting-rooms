import { BadRequestException, Controller, Get, ParseIntPipe, Query, Req, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { Room } from './interfaces/room.interface';
import { RoomsService } from './rooms.service';

@Controller('v1/rooms')
export class RoomsController {
    constructor(private roomsService: RoomsService) { }

    /**
     * Returns a list of rooms which are available for booking with their
     * status in 20 mins.
     * 
     * @param minutes number of minutes to which availablity needs to be checked (must be positive).
     */
    @Get('available')
    @UseGuards(AuthGuard('token'))
    getAvailableRooms(@Req() req, @Query('minutes', ParseIntPipe) minutes: number): Promise<Room[]> {
        if (minutes <= 0) {
            throw new BadRequestException("Parameter 'minutes' must be a positive number.");
        }

        return this.roomsService.getFreeRooms(req.user.token, minutes);
    }
}
