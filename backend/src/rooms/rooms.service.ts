import { Injectable, CacheTTL, UseInterceptors, CacheInterceptor } from '@nestjs/common';
import { google, admin_directory_v1, calendar_v3 } from 'googleapis';
import { Room } from './interfaces/room.interface';
import { OAuth2Client } from 'google-auth-library';
import { GaxiosResponse } from 'gaxios';
import * as moment from 'moment';

@Injectable()
export class RoomsService {
    constructor() { }

    /**
     * Returns the list of rooms which current account has access to.
     * 
     * @param accessToken user's access token
     */
    @CacheTTL(20)
    @UseInterceptors(CacheInterceptor)
    async getAllRooms(accessToken: string): Promise<Room[]> {
        const oauth2Client: OAuth2Client = new google.auth.OAuth2({
            clientId: process.env.GOOGLE_CLIENT_ID!,
            clientSecret: process.env.GOOGLE_CLIENT_SECRET!
        });

        oauth2Client.setCredentials({ access_token: accessToken });

        return new Promise<Room[]>((resolve, reject) => {
            const directory = google.admin({
                version: 'directory_v1',
                auth: oauth2Client
            });

            directory.resources.calendars.list({
                customer: 'my_customer',
                maxResults: 30,
                // TODO this query needs to be customizible
                query: process.env.RESOURCE_SEARCH_QUERY
            }, (err: Error | null, res?: GaxiosResponse<admin_directory_v1.Schema$CalendarResources> | null) => {
                if (err) {
                    return reject(err);
                }

                const rooms: Room[] =
                    res!.data.items!.map((item): Room => ({
                        id: item.resourceId,
                        email: item.resourceEmail,
                        name: item.resourceName,
                        floor: item.floorName,
                        capacity: item.capacity
                    }));

                resolve(rooms);
            });
        });
    }

    /**
     * Returns the list of rooms with their busy status for specified number of minutes.
     * 
     * @param accessToken user's access token
     * @param minutes number of minutes for busy status
     */
    async getFreeRooms(accessToken: string, minutes: number): Promise<Room[]> {
        const oauth2Client: OAuth2Client = new google.auth.OAuth2({
            clientId: process.env.GOOGLE_CLIENT_ID!,
            clientSecret: process.env.GOOGLE_CLIENT_SECRET!
        });

        oauth2Client.setCredentials({ access_token: accessToken });

        const rooms = await this.getAllRooms(accessToken);

        const minTime = moment().format();
        const maxTime = moment().add(minutes, "m").format();

        return new Promise<Room[]>((resolve, reject) => {
            const calendar = google.calendar({
                version: 'v3',
                auth: oauth2Client
            });

            const calendarIds = rooms.map(room => ({ "id": room.email }));

            calendar.freebusy.query({
                requestBody: {
                    items: calendarIds,
                    timeMin: minTime,
                    timeMax: maxTime
                }
            }, (err: Error | null, res?: GaxiosResponse<calendar_v3.Schema$FreeBusyResponse> | null) => {
                if (err) {
                    return reject(err);
                }

                const result = rooms
                    .filter(room => {
                        const errors = res?.data.calendars[room.email].errors || null;
                        return errors == null || errors.length == 0;
                    })
                    .map(room => ({
                        ...room,
                        busy: res!.data.calendars[room.email].busy
                    }));

                resolve(result);
            });
        });
    }
} 
