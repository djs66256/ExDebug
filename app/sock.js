// const {connecting, connected, disconnected} from '../actions/device'
// const store from '../store'
const net = require('net')
const UUID = require('uuid/v4')
const {app, BrowserWindow} = require('electron')
const {Device} = require('./device')

class Sock {

  constructor(deviceManager) {
    this.deviceManager = deviceManager
    this.server = null
  }

  listen() {
    this.server = net.createServer().listen(9000)
    console.log('server begin listen');

    this.server.on('connection', sock => {

      let id = UUID().replace(/-/g, '')
      console.log(`[${id}] device has connecting`);

      let device = new Device()
      device.id = id
      device.sock = sock
      this.deviceManager.addDevice(device)

      sock.on('data', (data) => {
          console.log(`[${sock.id}] receive data`);
          device.emit('data', data)
      })
      sock.on('disconnect', () => {
        console.log(`[${sock.id}] device has disconnected`);
        this.deviceManager.removeDevice(device)
      })
    })
  }
}

module.exports = Sock
