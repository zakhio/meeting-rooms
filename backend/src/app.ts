import { resolve } from 'path';
import { config } from "dotenv";
import { HomeController } from "./controllers/HomeController";
import { RoomsController } from "./controllers/RoomsController";
import { LocalhostCORS } from "./middleware/LocalhostCORS";
import { RequestLogger } from "./middleware/RequestLogger";
import { Server } from "./server";
import cookieParser = require("cookie-parser");

config({ path: resolve(__dirname, "../env.local") })

const app = new Server({
    port: 3001,
    controllers: {
        "/": HomeController(),
        "/rooms": RoomsController()
    },
    middleware: [
        RequestLogger,
        cookieParser(),
        LocalhostCORS,
        // ExpressSession({ secureCookie: process.env.NODE_ENV === 'production' })
    ]
})

app.listen()