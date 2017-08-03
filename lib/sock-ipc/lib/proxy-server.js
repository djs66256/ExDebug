/**
 桌面客户端的服务器
*/

const net = require('net')
const {MessageTypeRequest, MessageTypeRegister, MessageTypeProxyRequest} = require('./message')
const {ProxyClient} = require('./proxy-client')
const {ProxyManager} = require('./proxy-manager')

class ProxyServer {
  constructor({port=9001, requestManager}={}) {
    this.proxyManager = new ProxyManager({requestManager})

    this.server = net.createServer()
    this.port = port

    this.server.on('connection', sock=>{
      this.proxyManager.addProxySock(sock)
    })
  }

  start() {
    this.server.listen(this.port)
  }
}

module.exports = {ProxyServer}
