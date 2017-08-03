/**
 专门给桌面客户端使用，与server端无关，使用和requestManager一样，是为了实现客户端和服务端分离
*/
const {Socket} = require('net')
const {Message, MessageTypeRegister, MessageTypeRequest, MessageTypeProxyRequest} = require('./message')
const EventEmitter = require('events')

class AppClient extends EventEmitter {
  constructor({host='localhost', port=9001}={}) {
    super()
    this.host = host
    this.port = port
    this.connected = false
    this.requests = []
    this.id = 100
  }

  connect() {
    let sock = new Socket({readable: true, writable: true})
    sock.connect({
      host: this.host,
      port: this.port
    }, ()=>{})
    this.sock = sock

    this.sock.on('connect', ()=>{
      this.connected = true
      this.emit('connect')
    })
    let reconnect = ()=>{
      this.connected = false
      this.emit('close')
      setTimeout(() => {
        this.connect()
      }, 5000);
    }
    this.sock.on('close', reconnect)
    this.sock.on('error', reconnect)

    this.sock.on('data', data=>{
      let offset = 0
      do {
        let [len, msg] = Message.readFromData(data, offset)
        if (len <= 0) break
        offset += len
        msg.path && this.emit('message', msg)
        if (msg.type === MessageTypeProxyRequest) {
          let origMsg = msg.unwrapProxyMessage()
          if (origMsg.type === MessageTypeRegister) {
            this.emit('register', {deviceId: msg.path, message: origMsg})
          }
          else if (origMsg.type === MessageTypeRequest) {
            let callbackObj = this.requests.find(cb => cb.id === origMsg.id && cb.message.path === origMsg.path)
            if (callbackObj) {
              callbackObj.timeout && callbackObj.timeout.close()
              callbackObj.callback && callbackObj.callback(null, origMsg)
              this.requests = this.requests.filter(cb => cb != callbackObj)
            }
          }
        }
      } while (offset < data.length)
    })
  }

  request(src, deviceId, callback) {
    let msg = null
    if (typeof src === 'string') {
      msg = Message.request({path: src})
    }
    else if (src instanceof Message) {
      msg = src
    }
    else {
      msg = Message.request(src)
    }
    if (msg && msg.type === MessageTypeRequest && this.connected) {
      this.id ++
      if (this.id >= 1000000) {
        this.id = 100
      }
      msg.id = this.id

      let wrapMsg = msg.wrapProxyMessage()
      wrapMsg.path = deviceId || '0'
      wrapMsg.id = this.id
  console.log('wrapMsg: ', wrapMsg);
      this.sendMessage(wrapMsg)

      if (callback) {
        let callbackObj = {id: msg.id, message: msg, callback}
        this.requests.push(callbackObj)

        callbackObj.timeout = setTimeout(() => {
          callbackObj.callback(new Error('timeout!'))
          this.requests = this.requests.filter(cb => cb != callbackObj)
        }, msg.timeout||30000);
      }
    }
  }

  sendMessage(msg) {
    if (msg && this.connected) {
      let buf = msg.getBuffer()
      this.sock.write(buf)
    }
  }
}

module.exports = {AppClient}
