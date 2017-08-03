/**
  服务器需要处理的业务逻辑放在这儿
*/

class ServerService {

  constructor({devicesManager}) {
    this.devicesManager = devicesManager
  }

  dispatch(msg, callback) {
    if (msg.path === 'deviceList') {
      let devices = this.devicesManager.getDisplayDeviceInfos()
      let reply = msg.makeReplyMessage()
      reply.body = devices
      callback && callback(null, reply)
    }
    else {
      callback && callback(new Error('cannot dispatch message: ' + msg))
    }
  }
}

module.exports = {ServerService}
