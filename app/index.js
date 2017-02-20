const {setBasedir} = require('sock-ipc')

// let userdir = app.getPath('userData')
// console.log('UserData Dir: ', userdir);
// setBasedir(path.join(userdir))

setBasedir('/Users/daniel/Documents/tempdevice')

const {app, BrowserWindow, ipcMain} = require('electron')
const path = require('path')
const url = require('url')
const UUID = require('uuid/v4')
const os = require('os')
//const {devicesManager} = require('./server')
const {RequestManager, AppClient, ProxyServer, MessageTypeRequest, MessageTypeRegister} = require('sock-ipc')

let requestManager = new RequestManager()
let proxyManager = new ProxyServer({requestManager})

requestManager.on('ready', () => {
  setTimeout(function () {
    proxyManager.start()
  }, 100);
})

/*
let requestManager = new AppClient()
requestManager.connect()
*/

// let win
app.on('ready', () => {
 let  win = new BrowserWindow({width: 800, height: 600})
  win.deviceId = '0'
  win.webContents.deviceId = '0'
  const indexUrl = url.format({
    pathname: path.join(__dirname, 'index.html'),
    protocol: 'file:',
    slashes: true
  })

  win.loadURL(indexUrl)

  win.webContents.on('did-finish-load', function() {
    win.webContents.send('systemInfo', getSystemInfo())
  })
})

app.on('exit', () => {

})

app.on('window-all-closed', () => {
  app.quit()
})

ipcMain.on('open', (sender, deviceId) => {
  if (deviceId && deviceId !== 0) {
    let dwin = BrowserWindow.getAllWindows().find(w=>w.deviceId === deviceId)
    if (dwin) {
      dwin.focus()
    }
    else {
      dwin = new BrowserWindow({width: 800, height: 600})
      dwin.deviceId = deviceId
      dwin.webContents.deviceId = deviceId
      const deviceUrl = url.format({
        pathname: path.join(__dirname, 'device.html'),
        protocol: 'file:',
        slashes: true
      })
      dwin.loadURL(deviceUrl)
    }
  }
})

ipcMain.on('request', (event, req) => {
  let deviceId = event.sender.deviceId
  let id = req.id
  requestManager.request(req, deviceId, (error, msg) => {
    event.sender.send('request', {
      request: req,
      response: msg && Object.assign({}, msg, {id}),
      error
    })
  })
})

requestManager.on('register', ({deviceId, message}) => {
  if (deviceId && deviceId != 0) {
    const dwin = BrowserWindow.getAllWindows().find(w=>w.deviceId === deviceId)
    if (dwin) {
      dwin.webContents.send('register', {response: message})
    }
  }
  else {
    BrowserWindow.getAllWindows().forEach(w=>{
      w.webContents.send('register', {response: message})
    })
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
