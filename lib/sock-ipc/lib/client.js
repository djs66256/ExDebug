
const {Socket} = require('net')
const {Message, MessageTypeRegister, MessageTypeRequest, MessageTypeProxyRequest} = require('./message')
const EventEmitter = require('events')

class Client extends EventEmitter {
  constructor() {
    super()
    this.requests = []
    this.registers = []
    this.id = 100
    this.connected = false
    this.readBuffer = null
  }

  bindSocket(sock) {
    if (!sock) {
      this.emit('error', new Error('Client Error: sock cannot be null'))
      return
    }

    if (this.sock) {
      this.sock.end()
    }
    this.sock = sock

    this.sock.on('connect', ()=>{
      this.connected = true
      this.emit('connect')
    })
    this.sock.on('close', ()=>{
      this.connected = false
      this.sock = null
      this.emit('close')
    })
    this.sock.on('data', data=>{
      if (this.readBuffer) {
          data = Buffer.concat([this.readBuffer, data])
      }
      let offset = 0
      do {
        let [len, msg] = Message.readFromData(data, offset)
        if (len == -1) {
            // 需要第二个包
            this.readBuffer = data.slice(offset)
        }
        else {
            this.readBuffer = null
        }
        if (len <= 0) break

        offset += len
        msg.path && this.emit('message', msg)
        if (msg.type === MessageTypeRequest) {
          let callbackObj = this.requests.find(cb => cb.id === msg.id && cb.message.path === msg.path)
          if (callbackObj) {
            callbackObj.timeout && callbackObj.timeout.close()
            callbackObj.callback && callbackObj.callback(null, msg)
            this.requests = this.requests.filter(cb => cb != callbackObj)
          }
        }
        else if (msg.type === MessageTypeRegister) {
          msg.path && this.emit('register', msg)
        }
        else if (msg.type === MessageTypeProxyRequest) {
          this.emit('proxy', msg)
        }
      } while (offset < data.length)
    })
    // 此处延迟是为了确保连接已经完成，并且事件注册成功
    if (!this.sock.connecting && !this.sock.destroyed) {
      setTimeout(() => {
          this.connected = true
          this.emit('connect')
      }, 100);
    }
  }

  requestMessage({path, timeout=30000}, callback) {
console.log('REQUEST: ', path)
    if (path && path.length && this.connected) {
      let msg = Message.request({path, id: this.id})
      msg.timeout = timeout
      this.sendRequestMessage(msg, callback)
    }
  }
  request(path, callback) {
    if (path && path.length && this.connected) {
      this.requestMessage({path}, callback)
    }
  }

  register(path) {
    if (path && path.length && this.connected) {
      let msg = Message.register({path})
      this.sendMessage(msg)
    }
  }

  sendRequestMessage(msg, callback) {
    if (msg.type === MessageTypeRequest && this.connected) {
      this.id ++
      if (this.id >= 1000000) {
        this.id = 100
      }
      msg.id = this.id
      this.sendMessage(msg)

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
      if (buf) {
        this.sock.write(buf)
      }
    }
  }
}

module.exports = {Client}
