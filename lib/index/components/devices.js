import React from 'react'
import Device from './device'
import {ipcRenderer} from 'electron'

let devices = []
let updateHandler = null
ipcRenderer.on('deviceList', (sender, _devices) => {
  devices = _devices
  updateHandler && updateHandler(devices)
})

export default class Devices extends React.Component {

  constructor() {
    super()
    this.state = {devices}
    this.updateHandler = this.updateHandler.bind(this)
    this.onDoubleClick = this.onDoubleClick.bind(this)
  }

  componentDidMount() {
    updateHandler = this.updateHandler
  }

  componentWillUnmount() {
    updateHandler = null
  }

  updateHandler() {
    this.state.devices = devices
    this.setState(this.state)
    this.forceUpdate()
  }

  onDoubleClick(deviceId) {
    return ()=> {
      ipcRenderer.send(`open`, deviceId)
    }
  }

  render() {
    // const {devices} = this.state
    return (
      <div>
      {
        this.state.devices && this.state.devices.map(device => {
          return (
            <Device device={device}
              onDoubleClick={this.onDoubleClick(device.deviceId)}
              key={device.deviceId} />
            )
        })
      }
      </div>
    )
  }

}
