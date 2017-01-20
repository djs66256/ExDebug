import {SYS_INFO_RELOAD} from '../constants/sys-info'

const reducer = (state=[], action) => {
  switch (action.type) {
    case SYS_INFO_RELOAD:
      return action.payload
      break;
    default:
      return state
  }
}
export default reducer
