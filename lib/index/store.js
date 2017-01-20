
import {connect} from './reducers/device'
import systemInfo from './reducers/sys-info'
import {createStore, combineReducers} from 'redux'

let reducer = combineReducers({
  connection: connect,
  systemInfo
})

let store = createStore(reducer)

export default store
