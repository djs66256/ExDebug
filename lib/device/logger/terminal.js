import React from 'react'
import IPC from '../../ipc-request'

let logs = ['Console...']
let logStyles = [
    { filter: /DEBUG/, style: {backgroundColor: 'rgba(76, 175, 80, 0.1)'} },
    { filter: /INFO/, style: {} },
    { filter: /WARNING/, style: {backgroundColor: 'rgba(255, 193, 7,0.1)'} },
    { filter: /ERROR/, style: {backgroundColor: 'rgba(244, 67, 54, 0.1)'} },
]

class Terminal extends React.Component {

  constructor() {
    super()
    this.state = {logs}
    this.receiveData = this.receiveData.bind(this)
    this.componentDidUpdate = this.componentDidUpdate.bind(this)
  }

  componentDidMount() {
    IPC.register('logger', this.receiveData)
    // ipcRenderer.send('logger/on')
  }

  componentWillUnmount() {
    IPC.unregister('logger', this.receiveData)
  }

  componentDidUpdate() {
    const {scrollTop} = this.props
    scrollTop()
  }

  receiveData(data) {
    const {filters} = this.props
    if (filters && filters.length) {
      for (let filter of filters) {
        if (!filter(data)) {
          return
        }
      }
    }
    logs.push(data)
    if (logs.length > 10000) {
      logs = logs.slice(1000)
    }
    this.setState({logs})
  }

  styleForLog(log) {
      for (let item of logStyles) {
          if (log.match(item.filter)) {
              return item.style
          }
      }
      return null
  }

  render() {
    return(
      <div style={{width:'100%'}}>
      {
        logs && logs.map(log=>{
          return (
            <p style={ Object.assign({
              margin: '0 10px',
              color: 'white',
              fontFamily: 'monospace',
              whiteSpace: 'pre-wrap'
            }, this.styleForLog(log)) }>
              {log}
            </p>
          )
        })
      }
      </div>
    )
  }
}

export default Terminal
