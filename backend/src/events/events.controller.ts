import { Controller, Get, Res, HttpStatus, Param, NotFoundException, Post, Body, Put, Query, Delete } from '@nestjs/common';
import { EventsService } from './events.service';
import { CreateEventDTO } from './dto/create-event.dto';
import { ValidateObjectId } from './shared/pipes/validate-object-id.pipes';
import { CalendarEvent } from './interfaces/event.interface';

@Controller('v1/events')
export class EventsController {

    constructor(private eventsService: EventsService) { }

    // Submit a event
    @Post('/event')
    async addEvent(@Res() res, @Body() createEventDTO: CreateEventDTO) {
        const newEvent = await this.eventsService.addEvent(createEventDTO);
        return res.status(HttpStatus.OK).json({
            message: 'Event has been submitted successfully!',
            event: newEvent,
        });
    }

    // Fetch a particular event using ID
    @Get('event/:eventID')
    async getEvent(@Res() res, @Param('eventID', new ValidateObjectId()) eventID) {
        const event = await this.eventsService.getEvent(eventID);
        if (!event) {
            throw new NotFoundException('Event does not exist!');
        }
        return res.status(HttpStatus.OK).json(event);
    }

    // Fetch all events
    @Get('events')
    async getEvents(@Query('accessToken') accessToken: string): Promise<CalendarEvent[]> {
        const events = await this.eventsService.getEvents(accessToken);
        return events;
    }

    // Edit a particular event using ID
    @Put('/edit')
    async editEvent(
        @Res() res,
        @Query('eventID', new ValidateObjectId()) eventID,
        @Body() createEventDTO: CreateEventDTO,
    ) {
        const editedEvent = await this.eventsService.editEvent(eventID, createEventDTO);
        if (!editedEvent) {
            throw new NotFoundException('Event does not exist!');
        }
        return res.status(HttpStatus.OK).json({
            message: 'Event has been successfully updated',
            event: editedEvent,
        });
    }
    // Delete a event using ID
    @Delete('/delete')
    async deleteEvent(@Res() res, @Query('eventID', new ValidateObjectId()) eventID) {
        const deletedEvent = await this.eventsService.deleteEvent(eventID);
        if (!deletedEvent) {
            throw new NotFoundException('Event does not exist!');
        }
        return res.status(HttpStatus.OK).json({
            message: 'Event has been deleted!',
            event: deletedEvent,
        });
    }
}