import { NextFunction, Request, RequestHandler, Response } from 'express';

export const LocalhostCORS: RequestHandler = (req: Request, res: Response, next: NextFunction) => {
    res.header("Access-Control-Allow-Origin", "http://localhost:3000");
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
    res.setHeader('Access-Control-Allow-Credentials', "true");
    next();
}