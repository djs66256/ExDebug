import React from 'react'
import Component from '../component'
import CmdInput from '../components/cmd-input'
import {connect} from 'react-redux'
import {sendData} from '../actions/cmd-input'

class CmdInputContainer extends Component {
  render() {
    return (
      <CmdInput {...this.props} />
    )
  }
}

export default connect(
  state => {
    return {
      text: state.cmd.text
    }
  },
  dispatch => {
    return {
      sendData: data => sendData(dispatch, data)
    }
  })(CmdInputContainer)
