import { Request, RequestHandler, Response } from 'express';
import { google, admin_directory_v1, calendar_v3 } from 'googleapis';
import { GaxiosResponse } from 'gaxios';
import { OAuth2Client } from 'google-auth-library';

function listResources(auth: OAuth2Client, callback: (err: Error | null, res?: GaxiosResponse<admin_directory_v1.Schema$CalendarResources> | null) => void) {
  const directory = google.admin({ version: 'directory_v1', auth });
  directory.resources.calendars.list({
    customer: 'my_customer',
    maxResults: 30,
    query: "resourceCategory = CONFERENCE_ROOM AND buildingId = Munich"
  }, callback);
}

function freeBusy(auth: OAuth2Client, calendarIds: string[], callback: (err: Error | null, res?: GaxiosResponse<calendar_v3.Schema$FreeBusyResponse> | null) => void) {
  const calendar = google.calendar({ version: 'v3', auth });
  const items = calendarIds?.map(id => ({ "id": id }));
  calendar.freebusy.query({
    requestBody: {
      items,
      timeMin: "2020-03-06T11:54:23+00:00",
      timeMax: "2020-03-06T12:54:23+00:00"
    }
  }, callback);
}


export const RoomsController = (): RequestHandler => {

  return (req: Request, res: Response) => {
    const oauth2Client = new google.auth.OAuth2({
      clientId: process.env.GOOGLE_CLIENT_ID!,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET!
    });

    const sendFreeBusy = (calendarIds: string[]) => {
      freeBusy(oauth2Client, calendarIds, (err, result) => {
        if (err) {
          res.status(500).json(
            {
              stage: "2b",
              error: err
            }
          );
        } else {
          const answer = {
            data: result?.data.calendars,
            status: result?.status,
            statusText: result?.statusText
          };

          res.status(200).json(
            answer
          )
        }
      });
    }

    if (req.cookies?.accessToken != null) {
      oauth2Client.setCredentials({
        access_token: req.cookies.accessToken
      });

      listResources(oauth2Client, (err, result) => {
        if (err) {
          res.status(500).json(
            {
              stage: "1",
              error: err
            }
          );
        } else {
          const calendarIds = result?.data.items?.map(item => item.resourceEmail).filter(item => !(item === undefined || item == null));
          if (calendarIds == null || calendarIds === undefined) {
            return res.status(500).json(
              {
                stage: "2a",
                error: "No calendarIds"
              }
            );
          } else {
            sendFreeBusy(calendarIds as string[]);
          }
        }
      });
    } else {
      res.sendStatus(500);
    }
  }
}

