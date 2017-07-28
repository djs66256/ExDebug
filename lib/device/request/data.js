import EventEmitter from 'events'
import IPC from '../../ipc-request'

class RequestEmitter extends EventEmitter {
  constructor() {
    super()
    this.data = []

    IPC.register('request', (data) => {
      if (data) {
        this.data = [data].concat(this.data)
        if (this.data.length > 1000) {
          this.data = this.data.slice(900)
        }
        this.emit('changed', this.data)
        this.emit('request', data)
      }
    })
  }

  clear() {
    this.data = []
  }
}

export default new RequestEmitter()
