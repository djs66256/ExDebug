
const {EventEmitter} = require('events')

const DEVICE_IDLE = "DEVICE_IDLE"
const DEVICE_CONNECTED = "DEVICE_CONNECTED"

class Device extends EventEmitter {
  constructor() {
    super()
    this.state = DEVICE_IDLE
    this.id = ''
    this.sock = null
  }

  isConnected() {
    return this.state === DEVICE_CONNECTED
  }

  send(data) {
    if (this.sock) {
      this.sock.write(data)
    }
  }

}

class DeviceManager extends EventEmitter {
  constructor() {
    super()
    this.devices = []
  }

  addDevice(device) {
    this.devices.push(device)
    this.emit('add-device', {
      id: device.id
    })
  }

  removeDevice(device) {
    this.devices.pop(device)
    this.emit('remove-device', {
      id: device.id
    })
  }

  findDeviceById(id) {
    for (let device of this.devices) {
      if (device.id === id) {
        return device
      }
    }
    return null
  }
}


module.exports = {Device, DeviceManager}
