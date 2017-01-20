import React from 'react'
import Component from '../component'
import {connect} from 'react-redux'

import Devices from './devices'
import SystemInfo from './sys-info'

class ContentContainer extends Component {

  template(css) {
    return (
      <div>
      <SystemInfo className={css('sys-info')}/>
      <Devices className={css('devices')}/>
      </div>
    )
  }

  styles() {
    return {
      'sys-info': {
        'background-color': 'gray'
      },
      devices: {

      }
    }
  }
}

export default connect(
  state => {}
)(ContentContainer)
