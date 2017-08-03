/**
 所有与手机客户端有关的请求都从这里走
*/
const EventEmitter = require('events')

const {Message} = require('./message')
const {Server} = require('./server')
const {DevicesManager} = require('./device')
const {ServerService} = require('./server-service')

// event: ready register message
class RequestManager extends EventEmitter{
  constructor() {
    super()
    this.addListenToDevice = this.addListenToDevice.bind(this)
    this.devicesManager = new DevicesManager()
    this.devicesManager.on('ready', ()=>{
      this.devicesManager.devices.forEach(this.addListenToDevice)
      this.onUpdate()

      this.server = new Server({devicesManager:this.devicesManager})
      this.server.start()
      this.emit('ready')
    })
    this.devicesManager.on('addDevice', this.addListenToDevice)
    this.devicesManager.loadFromLocal()
    this.serverService = new ServerService({devicesManager:this.devicesManager})
  }

  onMessage({deviceId, message}) {
    this.emit('message', {deviceId, message})
  }
  onRegister({deviceId, message}) {
    this.emit('register', {deviceId, message})
  }
  onUpdate() {
    this.emit('update')
  }
  onConnect({deviceId}) {
    this.updateDeviceList()
    this.emit('connect', {deviceId})
  }
  onDisconnect({deviceId}) {
    this.updateDeviceList()
    this.emit('disconnect', {deviceId})
  }
  updateDeviceList() {
    let msg = {
      path:'deviceList',
      body: this.devicesManager.getDisplayDeviceInfos()
    }
    this.emit('register', {deviceId: '', message: Message.register(msg)})
  }

  addListenToDevice(d) {
    d.removeAllListeners()
    let deviceId = d.deviceInfo.deviceId
    d.on('message', message => this.onMessage({deviceId, message}))
    d.on('register', message => this.onRegister({deviceId, message}))
    d.on('connect', ()=>this.onConnect({deviceId}))
    d.on('close', ()=>this.onDisconnect({deviceId}))
  }

  request(msg, deviceId, callback) {
    let msgObj = null
    if (msg instanceof Message) {
      msgObj = msg
    }
    else if (typeof msg === 'string') {
      msgObj = Message.request({path: msg})
    }
    else {
      msgObj = Message.request(msg)
    }
    if (deviceId && deviceId != 0) {
      let device = this.devicesManager.devices.find(d=>d.deviceInfo.deviceId===deviceId)
      if (device) {
        device.sendRequestMessage(msgObj, callback)
      }
    }
    else {
      this.serverService.dispatch(msgObj, callback)
    }
  }
}

module.exports = {RequestManager}
