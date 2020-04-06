import { Injectable, UnauthorizedException } from "@nestjs/common";
import { PassportStrategy } from "@nestjs/passport";
import { IVerifyOptions, Strategy } from "passport-http-bearer";

@Injectable()
export class HttpBearerStrategy extends PassportStrategy(Strategy, 'token')
{
    constructor() {
        super()
    }

    validate(token: string, done: (error: any, user?: any, options?: IVerifyOptions | string) => void): void {
        if (token) {
            done(null, { token });
        } else {
            throw new UnauthorizedException('Missing token');
        }
    }

}