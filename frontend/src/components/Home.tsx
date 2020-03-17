import React from 'react';
import { Jumbotron } from 'reactstrap';

export function Home() {
    return (
        <div>
            <Jumbotron>
                <div className="container">
                    <div className="row row-header">
                        <div className="col-6 col-sm-6">
                            <h1>Meeting Room Finder</h1>
                            <p>Utilize your meeting rooms better.</p>
                        </div>
                    </div>
                </div>
            </Jumbotron>

            <div className="container" style={{ height: "600px" }}>
                <div className="row align-items-start">
                    <div className="col-12 col-md m-1">
                        How to use the meeting room finder app.
                </div>
                </div>
            </div>
        </div>
    );
}

export default Home;