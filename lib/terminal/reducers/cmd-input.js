import {CMD_INPUT_INIT, CMD_INPUT_NORMAL} from '../constants/cmd-input'

export default function (state = {text: ''}, action) {
  switch (action.type) {
    case CMD_INPUT_INIT:
      return {text: ''}
      break;
    case CMD_INPUT_NORMAL:
      return {text: action.payload}
      break;
    default:
      return state
  }
}
