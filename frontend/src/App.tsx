import React, { Component } from 'react';
import './App.css';
import Main from "./components/Main";
import { BrowserRouter } from "react-router-dom";
import { ConfigureStore } from "./redux/configureStore";
import { Provider } from "react-redux";
import { CookiesProvider } from 'react-cookie';

const store = ConfigureStore();

class App extends Component {
    render() {
        return (
            <CookiesProvider>
                <Provider store={store}>
                    <BrowserRouter>
                        <div>
                            <Main />
                        </div>
                    </BrowserRouter>
                </Provider>
            </CookiesProvider>
        );
    };
}

export default App;
