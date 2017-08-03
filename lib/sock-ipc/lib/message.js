/**
 这是我们的通信协议
 request：一对一请求，需要有返回
 register：push型，实时推送
 proxy：桌面客户端专用，用作请求转发，这时候path代表deviceId
*/
const MessageTypeRequest = 1
const MessageTypeRegister = 2
const MessageTypeProxyRequest = 3
/**
| 'SIPC' | type |
| id |
| length | path |
| length | head json |
| length | body |
*/
// id <100 留着备用
class Message {
  static request(params) {
    return new Message(Object.assign({type: MessageTypeRequest}, params))
  }
  static register(params) {
    return new Message(Object.assign({type: MessageTypeRegister}, params))
  }
  static reply(msg) {
    return new Message({
      type: msg.type,
      path: msg.path,
      id: msg.id
    })
  }

  constructor({type=MessageTypeRequest, path='', body='', id=0, head={}}) {
    this.type = type
    this.path = path
    this.body = body
    this.id = id
    this.head = head
  }

  makeReplyMessage() {
    return new Message({
      type: this.type,
      path: this.path,
      id: this.id
    })
  }
  wrapProxyMessage(source) {
    return new Message({
      type: MessageTypeProxyRequest,
      path: (source && source.path) || '0',
      id: (source && source.id) || 0,
      body: this.getBuffer()
    })
  }
  unwrapProxyMessage() {
    if (this.type === MessageTypeProxyRequest && (this.body instanceof Buffer)) {
      let [len, msg] = Message.readFromData(this.body)
      return msg
    }
    return null
  }

  // ret: [-1] 需要拼包；[-2] 包错误，需要丢弃； [len, msg] 
  static readFromData(buffer, offset = 0) {
    let startOffset = offset
    const sipc = buffer.toString('utf-8', offset, offset + 4)
//console.log('buffer: ',buffer.length, 'offset: ', offset, 'sipc: ', sipc);
    offset += 4
    if (sipc === 'SIPC') {
      // type
      const mType = buffer.readInt32BE(offset)
      offset += 4
      // id
      const id = buffer.readInt32BE(offset)
      offset += 4
      // path
      const pathLength = buffer.readInt32BE(offset)
      offset += 4
      const path = buffer.toString('utf-8', offset, offset + pathLength)
      offset += pathLength
      // head
      const headLength = buffer.readInt32BE(offset)
      offset += 4
      const headString = buffer.toString('utf-8', offset, offset + headLength)
      const head = headString && headString.length ? JSON.parse(headString) : {}
      offset += headLength
      // body
      const bodyLength = buffer.readInt32BE(offset)
      offset += 4
      if (bodyLength > buffer.length - offset) {
          // 需要下一个包进行拼包
          return [-1]
      }
      let body = null
      if (head.contentType === 'data') {
        body = new Buffer(bodyLength)
        buffer.copy(body, 0, offset, offset + bodyLength)
      }
      else {
        const bodyString = buffer.toString('utf-8', offset, offset + bodyLength)
        offset += bodyLength
        if (head.contentType === 'json') {
          body = bodyString && bodyString.length && JSON.parse(bodyString)
        }
        else {
          body = bodyString
        }
      }

      let msg = new Message({type: mType, path, body, id, head})
      return [offset-startOffset, msg]
    }
    return [-2]
  }

  getBuffer() {
    if (this.path) {
      let bodyString = null
      let bodyData = null
      if (this.body instanceof Buffer) {
        this.head.contentType = 'data'
        bodyData = this.body
      }
      else if (typeof this.body === 'string') {
        bodyString = this.body
        this.head.contentType = 'string'
      }
      else if (typeof this.body === 'object') {
        bodyString = JSON.stringify(this.body) || ''
        this.head.contentType = 'json'
      }
      const pathLength = Buffer.byteLength(this.path)
      const headString = this.head && JSON.stringify(this.head) || ''
      const headLength = headString ? Buffer.byteLength(headString) : 0
      const bodyLength = (bodyData && bodyData.length) || (bodyString && Buffer.byteLength(bodyString)) || 0
      const length = 8 + 4 + 4 + pathLength + 4 + headLength + 4 + bodyLength
      let offset = 0
      let buf = Buffer.alloc(length)
      buf.write('SIPC', offset)
      offset += 4
      // type
      buf.writeInt32BE(this.type, offset)
      offset += 4
      // id
      buf.writeInt32BE(this.id, offset)
      offset += 4
      // path
      buf.writeInt32BE(pathLength, offset)
      offset += 4
      buf.write(this.path, offset, pathLength)
      offset += pathLength
      // head
      buf.writeInt32BE(headLength, offset)
      offset += 4
      buf.write(headString, offset, headLength)
      offset += headLength
      // body
      buf.writeInt32BE(bodyLength, offset)
      offset += 4
      if (bodyLength > 0) {
        if (bodyData) {
          bodyData.copy(buf, offset, 0, bodyLength)
        }
        else {
          buf.write(bodyString, offset, bodyLength)
        }
      }
      // console.log("path: ", pathLength, " body: ", bodyLength, " buffer: ", buf);

      return buf
    }
    return null
  }
}


module.exports = {
  Message, MessageTypeRequest, MessageTypeRegister, MessageTypeProxyRequest
}
