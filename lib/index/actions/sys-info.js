import {SYS_INFO_RELOAD} from '../constants/sys-info'

export const updateSystemInfo = (dispatch, info) => {
  dispatch({
    type:SYS_INFO_RELOAD,
    payload: info
  })
}
