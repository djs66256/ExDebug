import React from 'react'
import IPC from '../../ipc-request'

let logs = ['Console...']

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

  render() {
    return(
      <div style={{width:'100%'}}>
      {
        logs && logs.map(log=>{
          return (
            <p style={{
              margin: '0 10px',
              color: 'white',
              fontFamily: 'monospace',
              whiteSpace: 'pre-wrap'
            }}>
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
