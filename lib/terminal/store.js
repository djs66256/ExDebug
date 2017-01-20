import {combineReducers, createStore} from 'redux'
import cmdInput from './reducers/cmd-input'
import textContent from './reducers/text-content'

import {receivedData} from './actions/text-content'
import {ipcRenderer} from 'electron'

let reducer = combineReducers({
  cmd: cmdInput,
  textContent: textContent
})

export let store = createStore(reducer)

let device = null
ipcRenderer.on('device-info', (sender, deviceInfo) => {
  device = deviceInfo
})

ipcRenderer.on('device-receive-data', (sender, data) => {
  receivedData(store.dispatch, data.toString())
})

export const sendDataToDevice = (data) => {
    ipcRenderer.send('device-send-data', {device, data})
}

// let i = 0
// const test = ()=>{
//   setTimeout(function () {
//     i++
//     receivedData(store.dispatch, 'MESSAGE OF '+i)
//     test()
//   }, 500);
// }
// test()
