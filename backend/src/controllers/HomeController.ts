import { Request, RequestHandler, Response } from 'express';

export const HomeController = (): RequestHandler => {
    console.log("HomeController");

    return (req: Request, res: Response) => {
        res.status(200).json(
            [
                `Current NODE_ENV is ${process.env.NODE_ENV}`,
                `Sample key is ${process.env.SAMPLE_KEY}`,
                'The sedulous hyena ate the antelope!'
            ]
        );
    }
}

