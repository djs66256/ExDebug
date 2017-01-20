import {TEXT_CONTENT_RECEIVED_DATA} from '../constants/text-content'

export default function (state = [], action) {
  switch (action.type) {
    case TEXT_CONTENT_RECEIVED_DATA:
      if (action.payload) {
        let lines = action.payload.split(/\r|\n/).filter(s => s && s.length)
        let newState = state.concat(lines)
        if (newState.length > 1000) {
          newState = newState.slice(0,800)
        }
        return newState
      }
      break;
    default:
  }
  return state
}
