import axios from 'axios'
 
const USERS_LIST_REST_API_URL = 'http://localhost:8080/teller-api/users/list';
 
class UserService {
 
    getUsers(){
        return axios.get(USERS_LIST_REST_API_URL);
    }
}

export default new UserService();