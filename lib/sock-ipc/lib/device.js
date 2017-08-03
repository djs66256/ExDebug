/**
 这是手机客户端的实体类与管理类
*/

const fs = require('fs')
const path = require('path')
const {Client} = require('./client')
const {getDeviceInfosFilePath} = require('./path')
const EventEmitter = require('events')

class Device extends Client {
  constructor({deviceInfo}) {
    super()
    this.deviceInfo = deviceInfo || {}
    this.connected = false
  }

  updateDeviceInfo(deviceInfo) {
    Object.assign(this.deviceInfo, deviceInfo)
    this.emit('updateDeviceInfo', this.deviceInfo)
  }

  getDisplayDeviceInfo() {
    let obj = Object.assign({connected: this.connected}, this.deviceInfo);
    return obj
  }

}

class DevicesManager extends EventEmitter {

  constructor() {
    super()
    this.devices = []
    this.ready = false
  }

  addDeviceInfo(deviceInfo) {
    if (this.ready) {
      let localDevice = this.devices.find(device => device.deviceInfo.deviceId === deviceInfo.deviceId)
      if (!localDevice) {
        localDevice = new Device({deviceInfo})
        this.devices.push(localDevice)
        this.emit('newDevice', localDevice)
      }
      else {
        localDevice.updateDeviceInfo(deviceInfo)
        this.emit('updateDevice', localDevice)
      }
      this.emit('addDevice', localDevice)
      return localDevice
    }
    else {
      this.emit('error', new Error('Devices manager should be ready before add any device'))
    }
  }

  saveDevices() {
    let infos = this.devices.map(d => d.deviceInfo)
    let jsonString = JSON.stringify(infos, null, 4)
    getDeviceInfosFilePath().then(fp => {
      fs.writeFile(fp, jsonString, err => {

      })
    }).catch(e=>console.log(e))
  }

  loadFromLocal() {
    getDeviceInfosFilePath().then(fp => {
      if (fs.existsSync(fp)) {
        fs.readFile(fp, (err, data) => {
          if (err) {
            this.emit('error', err)
          }
          else {
            let infos = JSON.parse(data.toString())
            if (infos && infos.length) {
              this.devices = infos.map(deviceInfo => new Device({deviceInfo}))
            }
            this.ready = true
            this.emit('ready')
          }
        })
      }
      else {
        this.ready = true
        this.emit('ready')
      }
    }).catch(e => this.emit('error', e))
  }

  findDeviceById(deviceId) {
    return this.devices.find(d=>d.deviceInfo.deviceId === deviceId)
  }

  getDisplayDeviceInfos() {
    return this.devices.map(d=>d.getDisplayDeviceInfo())
  }

}

module.exports = {DevicesManager, Device}
