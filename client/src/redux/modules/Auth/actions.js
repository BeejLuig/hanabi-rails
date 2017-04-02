import { reset } from 'redux-form';
import ApiService from '../../../services/Api';
import fetch from 'isomorphic-fetch';

/**
 * @param {Auth} creator actions
 */
export const setCurrentUser = (user) => {
  return {
    type: 'AUTHENTICATION_SUCCESS', 
    user
  };
}

export const authenticationRequest = () => {
  return { type: 'AUTHENTICATION_REQUEST' };
}

/**
 * @param {Auth} async actions
 */

export const signup = (data, router) => {
  return dispatch => {
    dispatch(authenticationRequest());
    return ApiService.post('/users', { data })
      .then(response => {
        const { user, token } = response;
        localStorage.setItem('token', JSON.stringify(token));
        dispatch(setCurrentUser(user));
        dispatch(reset('signup'));
        router.history.replace('/games');
      });
  }
}