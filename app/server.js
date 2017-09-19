const {Server} = require('../lib/sock-ipc')
const {ipcMain} = require('electron')
const {DevicesManager} = require('../lib/sock-ipc')

let devicesManager = new DevicesManager()
devicesManager.loadFromLocal()
let server
devicesManager.on('ready', () => {
  server = new Server({devicesManager})
  server.start()
})

module.exports = {devicesManager, server}

// devicesManager.on('addDevice', d => {
//   console.log('add device: ', d.deviceInfo);
//   d.on('connect', ()=> {
//     console.log('register => logger/on');
//     d.register('logger/on')
//     console.log('reqeust => deviceInfo');
//     d.request('deviceInfo', (err, msg) => {
//       console.log('err: ', err, ' msg: ', msg);
//     })
//   })
//   d.on('message', msg => {
//     console.log('device message: ', msg);
//   })
// })
// devicesManager.on('error', err => {
//   console.log('DevicesManager error: ', err)
// })
