import {TEXT_CONTENT_RECEIVED_DATA} from '../constants/text-content'

export const receivedData = (dispatch, data) => {
  dispatch({
    type: TEXT_CONTENT_RECEIVED_DATA,
    payload: data
  })
}
