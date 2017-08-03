const {mkdirs} = require('./util')
const path = require('path')

let basedir = '.'
const setBasedir = dir => {
  basedir = dir
}

const getDeviceInfosDirectory = () => {
  let dir = path.join(basedir, 'info')
  return mkdirs(dir, '777')
}

const getDevicesHomeDirectory = () => {
  let dir = path.join(basedir, 'devices')
  return mkdirs(dir, '777')
}

const getDeviceInfosFilePath = () => {
  return getDeviceInfosDirectory().then(dir => path.join(dir, 'devices.json'))
}

const getDeviceDirectory = deviceId => {
  return new Promise((resovle, reject) => {
    getDevicesHomeDirectory().then(dir => path.join(dir, deviceId)).then(dir => {
      mkdirs(dir, '777').then(resovle).catch(reject)
    }).catch(reject)
  })
}

module.exports = {setBasedir, getDeviceInfosFilePath, getDeviceDirectory}
