import { CacheModule, Module } from '@nestjs/common';
import { RoomsController } from './rooms.controller';
import { RoomsService } from './rooms.service';

/**
 * Module for Rooms. 
 * 
 * It uses Google Calendar Resource Directory to determine settings of rooms.
 * 
 * @see [Resources.calendars documentation](https://developers.google.com/admin-sdk/directory/v1/reference/resources/calendars#resource)
 */
@Module({
  imports: [CacheModule.register()],
  controllers: [RoomsController],
  providers: [RoomsService],
  exports: [RoomsService]
})
export class RoomsModule { }
