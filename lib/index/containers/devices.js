import React from 'react'
import {connect} from 'react-redux'
import Devices from '../components/devices'
import {openNewWindow} from '../actions/device'

export default connect(
  state => {
    return {
      devices: state.connection.devices
    }
  },
  dispatch => {
    return {
      onDoubleClick: (device) => (() => openNewWindow(device))
    }
  })(Devices)
