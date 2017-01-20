
const UUID = require('uuid/v4')
const path = require('path')
const url = require('url')
const {app, BrowserWindow} = require('electron')

const debug = false

class App {
  constructor() {
    this.mainWindow = null
    this.childrenWindows = []
  }

  createWindow(url, device_id) {
    let win = new BrowserWindow({width: 800, height: 600})
    win.device_id = 0
    win.loadURL(url)

    if (debug) win.webContents.openDevTools()

    return win
  }

  createMainWindow() {
    let URL = url.format({
      pathname: path.join(__dirname, 'index.html'),
      protocol: 'file:',
      slashes: true
    })
    this.mainWindow = this.createWindow(URL)
    this.mainWindow.on('close', () => {
      this.mainWindow = null
    })

    return this.mainWindow
  }

  createChildWindowWithFile(file, device_id) {
    let URL = url.format({
      pathname: path.join(__dirname, file),
      protocol: 'file:',
      slashes: true
    })
    return this.createChildWindow(URL, device_id)
  }

  createChildWindow(url, device_id) {
    let win = this.createWindow(url, device_id)
    if (win) {
      this.childrenWindows.push(win)
      win.on('closed', () => {
        this.removeChildWindow(win)
      })
    }
    return win
  }

  removeChildWindowById(device_id) {
    let win = this.getWindowById(device_id)
    this.removeChildWindow(win)
  }

  removeChildWindow(win) {
    if (win) {
      this.childrenWindows = this.childrenWindows.filter(aWin => aWin !== win)
    }
  }

  getWindowById(device_id) {
    for (win of this.childrenWindows) {
      if (win.device_id === device_id) {
        return win
      }
    }
    return null
  }
}

module.exports = App
