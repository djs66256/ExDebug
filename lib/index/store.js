
import {connect} from './reducers/device'
import systemInfo from './reducers/sys-info'
import {createStore, combineReducers, applyMiddleware} from 'redux'


let reducer = combineReducers({
  connection: connect,
  systemInfo
})

import createLogger from 'redux-logger';
const logger = createLogger();
const store = createStore(reducer, applyMiddleware(logger))

export default store
