import express, { Application, RequestHandler } from "express";

/**
 * Configuration of the servers.
 */
interface ServerConfig {
    port: number;
    middleware?: RequestHandler[];
    controllers: { [path: string]: RequestHandler };
}

export class Server {
    private expressApp: Application;
    private port: number;

    constructor(config: ServerConfig) {
        this.expressApp = express();
        this.expressApp.disable('x-powered-by');

        this.port = config.port;

        this.setupMiddleware(config.middleware);
        this.setupControllers(config.controllers);
    }

    /**
     * Setup middleware function which will be called on each request.
     *
     * @param middleware list of RequestHandlers
     */
    private setupMiddleware(middleware?: RequestHandler[]) {
        middleware?.forEach(m => {
            this.expressApp.use(m);
        });
    }

    /**
     * Setup request handlers for the sever.
     *
     * @param controllers map of controllers where the key is path
     */
    private setupControllers(controllers: { [path: string]: RequestHandler }) {
        for (const path in controllers) {
            if (controllers.hasOwnProperty(path)) {
                const handler = controllers[path];
                this.expressApp.get(path, handler);
            }
        }
    }

    /**
     * Start listening incoming connections on port specified in the constructor.
     */
    public listen() {
        this.expressApp.listen(this.port, err => {
            if (err) {
                return console.error(err);
            }
            return console.log(`Server is listening on ${this.port}`);
        });
    }
}