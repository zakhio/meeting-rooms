import { Document } from "mongoose";

export interface Event extends Document {
  readonly title: string;
  readonly description: string;
  readonly body: string;
  readonly author: string;
  readonly date_posted: string;
}

export interface CalendarEvent {
  readonly author: string;
  readonly email: string;
  readonly description: string;
  readonly start: string;
  readonly location: string;  
}