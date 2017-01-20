import React from 'react'
import Device from './device'
import Component from '../component'

export default class Devices extends Component {

  template(css) {
    const {devices, onDoubleClick} = this.props
    return (
      <div>
      {
        devices && devices.map(device => {
          return <Device device={device} onDoubleClick={onDoubleClick} />
        })
      }
      </div>
    )
  }

  styles() {
    return {

    }
  }

}
