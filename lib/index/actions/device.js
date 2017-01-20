
import {DEVICE_INIT, DEVICE_WAITING, DEVICE_CONNECTING, DEVICE_CONNECTED, DEVICE_DISCONNECTED} from '../constants/device'
import {ipcRenderer} from 'electron'

export const initial = (dispatch, devices) => {
  dispatch({
    type: DEVICE_INIT,
    payload: devices
  })
}

export const connecting = (dispatch, device) => {
  dispatch({
    type: DEVICE_CONNECTING,
    payload: device
  })
}

export const connected = (dispatch, device) => {
  dispatch({
    type: DEVICE_CONNECTED,
    payload: device
  })
}

export const disconnected = (dispatch, device) => {
  dispatch({
    type: DEVICE_CONNECTED,
    payload: device
  })
}

export const openNewWindow = (device) => {
  ipcRenderer.send('open-terminal', device)
}
