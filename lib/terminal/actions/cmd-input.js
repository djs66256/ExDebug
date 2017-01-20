import {CMD_INPUT_INIT, CMD_INPUT_NORMAL} from '../constants/cmd-input'
import {sendDataToDevice} from '../store'

export const sendData = (dispatch, data) => {
  sendDataToDevice(data)
  dispatch({
    type: CMD_INPUT_INIT
  })
}
