import React, {useState} from "react";
import axios from "axios";
import {useHistory} from "react-router-dom";


const Login = (key, value) => {

    const history = useHistory();
    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const [error, setError] = useState("");

    function handleSubmit(event) {
        event.preventDefault();
        axios.post(`${process.env.REACT_APP_API_URL}/apv/v27/user/login`, {
            username: email,
            password: password
        }, {
            headers: {
                "Content-Type": "application/json",
                "apikey": process.env.REACT_APP_DEV_API_KEY
            }
        }).then( r => {
            localStorage.setItem("username", email);
            localStorage.setItem("authHash", r.data.service_authhash);
            localStorage.setItem('token', r.data.token)
            history.push('/home')
        }).catch(e => {
            setError(e.response.data.reason);
        })

    }

    return (
        <div className="w-25 mh-100">
            <form onSubmit={handleSubmit}>
                <div className="form-group m-2">
                    <label htmlFor="email">Email address</label>
                    <input
                        className="form-control my-2"
                        required
                        id="email"
                        type="email"
                        name="username"
                        placeholder="Email address"
                        onChange={(e) => setEmail(e.target.value)}
                    />
                </div>
                <div className="form-group m-2">
                    <label htmlFor="password">Password</label>
                    <input
                        className="form-control my-2"
                        id="password"
                        required
                        type="password"
                        name="password"
                        placeholder="Password"
                        onChange={(e) => setPassword(e.target.value)}
                    />
                </div>
                <button type="submit" className="btn btn-primary m-2">Submit</button>
            </form>
            {error && <div>{error}</div>}
        </div>
    )
}

export default Login;
