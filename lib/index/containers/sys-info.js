import {connect} from 'react-redux'
import SystemInfo from '../components/sys-info'

export default connect(
  state => {
    return {
      systemInfo: state.systemInfo
    }
  },
  dispatch => {
    return  {}
  }
)(SystemInfo)
