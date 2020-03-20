import { Module, NestModule, MiddlewareConsumer, RequestMethod } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { EventSchema } from 'src/events/schemas/event.schema';
import { EventsController } from './events.controller';
import { EventsService } from './events.service';
import { AuthenticationMiddleware } from 'src/common/authentication.middleware';

/**
 * Module for Events management.
 * 
 * It uses Google Calendar Event to determine events.
 * 
 * @see [Event documentation](https://developers.google.com/calendar/v3/reference/events)
 */
@Module({
  imports: [
    MongooseModule.forFeature([{ name: 'Event', schema: EventSchema }]),
  ],
  providers: [EventsService],
  controllers: [EventsController]
})

export class EventsModule implements NestModule {
  configure(consumer: MiddlewareConsumer): MiddlewareConsumer | void {
    consumer.apply(AuthenticationMiddleware).forRoutes(
      { method: RequestMethod.POST, path: '/event/post' },
      { method: RequestMethod.PUT, path: '/event/edit' },
      { method: RequestMethod.DELETE, path: '/event/delete' }
    )
  }
}
