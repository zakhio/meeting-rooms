import { CacheModule, Module } from '@nestjs/common';
import { RoomsController } from './rooms.controller';
import { RoomsService } from './rooms.service';

@Module({
  imports: [CacheModule.register()],
  providers: [RoomsService],
  exports: [RoomsService],
  controllers: [RoomsController]
})
export class RoomsModule { }
