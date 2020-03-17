import session from 'express-session'
import { RequestHandler } from 'express';

export const ExpressSession = ({ secureCookie }: { secureCookie: boolean }) => session({
    saveUninitialized: true,
    resave: false,
    secret: 'sssh, quiet! it\'s a secret!',
    cookie: {
        maxAge: 1000 * 60 * 60 * 2,
        sameSite: false,
        secure: secureCookie
    }
});