/**
 桌面客户端请求的管理、装包与拆包
*/

const {Message} = require('./message')
const {ProxyClient} = require('./proxy-client')

// EVENTS: request register
class ProxyManager {

  constructor({requestManager}) {
    this.clients = []
    this.requestManager = requestManager
    this.requestManager.on('register', this.onRegister.bind(this))
    this.requestManager.on('connect', this.onConnect.bind(this))
    this.requestManager.on('disconnect', this.onDisconnect.bind(this))
  }

  addProxySock(sock) {
    let client = new ProxyClient()
    client.bindSocket(sock)
    this.addProxyClient(client)
    client.on('close', () => {
      this.removeProxyClient(client)
    })
  }

  addProxyClient(client) {
    this.clients.push(client)
    client.on('proxy', msg => {
      let deviceId = msg.path
      let message = msg.unwrapProxyMessage()
      if (message) {
        let id = message.id
        this.requestManager.request(message, deviceId, (error, response) => {
          response.id = id
          let proxyResponse = response.wrapProxyMessage(msg)
          client.sendMessage(proxyResponse)
        })
      }
    })
  }
  removeProxyClient(client) {
    this.clients = this.clients.filter(c=>c!==client)
  }

  onRegister({deviceId, message}) {
    if (message) {
      let resp = message.wrapProxyMessage()
      resp.path = deviceId
      this.clients.forEach(client => {
        client.sendMessage(resp)
      })
    }
  }
  onUpdate() {

  }
  onConnect() {
    // this.updateDeviceList()
  }
  onDisconnect() {
    // this.updateDeviceList()
  }

  updateDeviceList() {
    let msg = {
      path:'deviceList',
      body: this.requestManager.devicesManager.getDisplayDeviceInfos()
    }
    this.sendMessageToAllClient(msg)
  }

  sendMessageToAllClient(msg) {
    let msgObj = null
    if (msg instanceof Message) {
      msgObj = msg
    }
    else if (typeof msg === 'string') {
      msgObj = Message.register({path:msg})
    }
    else {
      msgObj = Message.register(msg)
    }
    let wrapMsg = msgObj.wrapProxyMessage()
    this.clients.forEach(client => {
      client.sendMessage(wrapMsg)
    })
  }
}

module.exports = {ProxyManager}
