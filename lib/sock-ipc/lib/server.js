/**
 这是手机客户端连接的服务器
*/

const net = require('net')
const {Message} = require('./message')
const EventEmitter = require('events')
const {DevicesManager, Device} = require('./device')
// const {Device} = require('./device')

class Server extends EventEmitter {
  constructor({port=9000, devicesManager}={}) {
    super()
    this.devicesManager = devicesManager
    this.server = net.createServer()
    this.port = port

    this.server.on('connection', sock => {
      let msg = Message.request({path:'deviceInfo'})
      let buf = msg.getBuffer()
      sock.write(buf)

      const timeout = setTimeout(function () {
        sock.end()
      }, 10000);

      const reply = data => {
        let offset = 0
// console.log('receive deviceInfo: ', data);
        do {
          let [len, msg] = Message.readFromData(data, offset)
          if (len <= 0) break
          offset += len
          if (msg.path === 'deviceInfo' && msg.body) {
            // find a device
            sock.removeListener('data', reply)
            timeout.close()
            let device = this.devicesManager.addDeviceInfo(msg.body)
            device.bindSocket(sock)
            this.devicesManager.saveDevices()
            return
          }
        } while (offset < data.length)
      }
      sock.on('data', reply)
    })
  }

  start() {
    this.server.listen(this.port)
  }
}

module.exports = {Server}
