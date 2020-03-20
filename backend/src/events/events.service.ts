import { Injectable } from '@nestjs/common';
import { Model } from 'mongoose';
import { InjectModel } from '@nestjs/mongoose';
import { Event, CalendarEvent } from './interfaces/event.interface';
import { CreateEventDTO } from './dto/create-event.dto';
import { OAuth2Client } from 'google-auth-library';
import { google, calendar_v3 } from 'googleapis';
import { GaxiosResponse } from 'gaxios';

@Injectable()
export class EventsService {
    constructor(@InjectModel('Event') private readonly eventModel: Model<Event>) { }

    async addEvent(createEventDTO: CreateEventDTO): Promise<Event> {
        const newEvent = await this.eventModel.create(createEventDTO);
        return newEvent.save();
    }

    async getEvent(eventID): Promise<Event> {
        const event = await this.eventModel
            .findById(eventID)
            .exec();
        return event;
    }

    /**
     * Returns the list of future calendar events for user.
     * 
     * @param accessToken user's access token
     */
    async getEvents(accessToken: string): Promise<CalendarEvent[]> {
        const oauth2Client: OAuth2Client = new google.auth.OAuth2({
            clientId: process.env.GOOGLE_CLIENT_ID!,
            clientSecret: process.env.GOOGLE_CLIENT_SECRET!
        });

        oauth2Client.setCredentials({ access_token: accessToken });

        return new Promise<CalendarEvent[]>((resolve, reject) => {
            const calendar = google.calendar({
                version: 'v3',
                auth: oauth2Client
            });

            calendar.events.list({
                calendarId: 'primary',
                timeMin: (new Date()).toISOString(),
                maxResults: 10,
                singleEvents: true,
                orderBy: 'startTime',
            }, (err: Error | null, res?: GaxiosResponse<calendar_v3.Schema$Events> | null) => {
                if (err) {
                    return reject(err);
                }

                const events: CalendarEvent[] =
                    res!.data.items!.map((item): CalendarEvent => ({
                        author: item.creator.displayName,
                        email: item.creator.email,
                        description: item.description,
                        location: item.location,
                        start: item.start.dateTime
                    }));

                resolve(events);
            })
        });
    }

    async editEvent(eventID, createEventDTO: CreateEventDTO): Promise<Event> {
        const editedEvent = await this.eventModel
            .findByIdAndUpdate(eventID, createEventDTO, { new: true });
        return editedEvent;
    }

    async deleteEvent(eventID): Promise<any> {
        const deletedEvent = await this.eventModel
            .findByIdAndRemove(eventID);
        return deletedEvent;
    }
} 