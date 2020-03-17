import { NextFunction, Request, RequestHandler, Response } from 'express'

export const RequestLogger: RequestHandler = (req: Request, res: Response, next: NextFunction) => {
    console.log('Request logged:', req.method, req.path);
    next();
}