import axios from "axios";
import createAuthRefreshInterceptor from "axios-auth-refresh";
import {useHistory} from "react-router-dom";

const axiosService = axios.create({
    baseURL: process.env.REACT_APP_API_URL,
    headers: {
        'Content-Type': 'application/json',
        'apikey': process.env.REACT_APP_DEV_API_KEY
    }
});

axiosService.interceptors.request.use(async (config) => {
    const token = localStorage.getItem('token');

    if (token){
        config.headers.token = token;
        console.debug('[Request]', config.baseURL + config.url, JSON.stringify(token));
    }

    return config;
})


axiosService.interceptors.response.use(
    (res) => {
        console.debug('[Response]', res.config.baseURL + res.config.url, res.status, res.data);
        return Promise.resolve(res);
    },
    (err) => {
        console.debug(
            '[Response]',
            err.config.baseURL + err.config.url,
            err.response.status,
            err.response.data
        );
        return Promise.reject(err);
    }
);

const refreshAuthLogic = async (failedRequest) => {
    const authHash = localStorage.getItem('authHash')
    const username = localStorage.getItem('username');

    // eslint-disable-next-line react-hooks/rules-of-hooks
    const history = useHistory();
    if (authHash) {
        return axios
            .post(
                '/apv/v27/user/login',
                {
                    username: username,
                    authhash: authHash
                },
                {
                    baseURL: process.env.REACT_APP_API_URL
                }
            )
            .then((resp) => {
                const { token, service_authhash } = resp.data;
                failedRequest.response.config.headers.token = token;
                localStorage.setItem("authHash", service_authhash);
                localStorage.setItem('token', token);
            })
            .catch((err) => {
                if (err.response && err.response.status === 401){
                    history.push('/login');
                }
            });
    }
};

createAuthRefreshInterceptor(axiosService, refreshAuthLogic);

export function fetcher(url, data) {
    return axiosService.post(url, data).then((res) => res.data);
}

export default axiosService;
