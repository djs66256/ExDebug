import IPC from '../../ipc-request'
import EventEmitter from 'events'

class RunloopData extends EventEmitter {
  constructor() {
    super()

    this.data = []
    IPC.register('runloop', data => {
      this.data = [data].concat(this.data)
      if (this.data.length > 2000) {
        this.data.slice(1900)
      }
      this.emit('changed', this.data)
      this.emit('runloop', data)
    })
  }

  clear() {
    this.data = []
  }

  getChartData() {
    let map = {}
    this.data.forEach(d => {
      let a = 0.2
      if (d.duration < 1) {
        for (var i = 0.05; i < 1; i += 0.05) {
          if (d.duration < i) {
            if (!map[i]) {
              map[i] = 1
            }
            else {
              map[i] ++
            }
            break
          }
        }
      }
      else {
        map[i] ? map[i]++ : map[i] = 1
      }
    })
    return Object.keys(map).map(k => {
      return {value: map[k], name: (Math.round(k*100)/100).toString()}
    })
  }
}

export default new RunloopData()
