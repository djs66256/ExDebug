const {app, BrowserWindow, ipcMain} = require('electron')
const path = require('path')
const url = require('url')
const UUID = require('uuid/v4')
const os = require('os')

const AppHelper = require('./app')
const {Device, DeviceManager} = require('./device')
const Sock = require('./sock')

let deviceManager = new DeviceManager()
let appHelper = new AppHelper()
let sock = new Sock(deviceManager)
sock.listen()

app.on('ready', () => {
  let win = appHelper.createMainWindow() // new BrowserWindow({width: 800, height: 600})

  deviceManager.on('add-device', function(device) {
    win.webContents.send('add-device', device)
  })
  deviceManager.on('remove-device', function(device) {
    win.webContents.send('remove-device', device)
  })
  win.webContents.on('did-finish-load', function() {
    win.webContents.send('system-info', getSystemInfo())
    win.webContents.send('device-list', deviceManager.devices)
  })
  // win.loadURL(url.format({
  //   pathname: path.join(__dirname, 'index.html'),
  //   protocol: 'file:',
  //   slashes: true
  // }))
  //
  // win.webContents.openDevTools()
  //
  // win.on('close', () => {
  //   win = null
  // })
})

app.on('exit', () => {

})

app.on('window-all-closed', () => {
  app.quit()
})

ipcMain.on('open-terminal', (sender, aDevice) => {
  console.log('device: ', aDevice);
  let device = deviceManager.findDeviceById(aDevice.id)
  if (!device) {
    console.error('Cannot find a device by ', aDevice.id);
    return
  }
  console.log('open-terminal ', device.id);
  let win = appHelper.createChildWindowWithFile('terminal.html', device.id)
  device.win = win

  win.webContents.on('did-finish-load', function() {
    win.webContents.send('device-info', device)
  })

  win.dataListener = function(data) {
    win.webContents.send('device-receive-data', data)
  }
  device.on('data', win.dataListener)

  win.on('close', function() {
    console.log('close', win.dataListener);
    device.removeListener('data', win.dataListener)
    // appHelper.removeChildWindow(win)
  })

})

ipcMain.on('device-send-data', (sender, {device, data}) => {
  console.log('device-send-data ', data.toString());
  let deviceObj = deviceManager.findDeviceById(device.id)
  if (deviceObj) {
    deviceObj.send(data+'\n')
  }
})

function getSystemInfo() {
  let netInfos = os.networkInterfaces()
  let arr = []
  for (key of Object.keys(netInfos)) {
      for (info of netInfos[key]) {
          if (info.address !== '127.0.0.1'
            && info.family.toLowerCase() === 'ipv4'
        /*&& info.address.match(/^\d+\.\d+\.\d+\.\d+$/)*/) {
                arr.push(info)
          }
      }
  }

  return arr
}
