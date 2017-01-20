import {DEVICE_INIT, DEVICE_WAITING, DEVICE_CONNECTING, DEVICE_CONNECTED} from '../constants/device'

export const connect = (state={}, action) => {
  let devices = state.devices || []
  switch (action.type) {
    case DEVICE_INIT:
      return {
        type: DEVICE_INIT,
        devices: action.payload || []
      }
      break;
    case DEVICE_WAITING:
      return {
        type: DEVICE_WAITING,
        devices: devices
      }
      break;
    case DEVICE_CONNECTING:
      return {
        type: DEVICE_CONNECTING,
        devices: devices
      }
      break;
    case DEVICE_CONNECTED:
      return {
        type: DEVICE_CONNECTED,
        devices: devices.concat(action.payload)
      }
      break
    default:
      return {
        type: DEVICE_WAITING,
        devices: devices
      }
  }
}
