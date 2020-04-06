import { Module } from '@nestjs/common';
import { PassportModule } from '@nestjs/passport';
import { HttpBearerStrategy } from './http-bearer.strategy';

@Module({
  imports: [
    PassportModule
  ],
  providers: [HttpBearerStrategy]
})
export class AuthModule { }
