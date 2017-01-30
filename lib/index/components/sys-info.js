import React from 'react'
import {Button, Modal} from 'antd'
import {ipcRenderer} from 'electron'

let systemInfo = []
let updateHandler = null
ipcRenderer.on('systemInfo', (sender, data) => {
  systemInfo = data
  updateHandler && updateHandler(data)
})

export default class SystemInfo extends React.Component {

  constructor() {
    super()
    this.state = {visible: false, systemInfo}
    this.showModal = this.showModal.bind(this)
    this.handleOk = this.handleOk.bind(this)
    this.handleCancel = this.handleCancel.bind(this)
    this.updateHandler = this.updateHandler.bind(this)
  }

  componentDidMount() {
    updateHandler = this.updateHandler
  }

  componentWillUnmount() {
    updateHandler = null
  }

  showModal() {
    this.state.visible = true
    this.setState(this.state)
  }
  handleOk() {
    this.state.visible = false
    this.setState(this.state);
  }
  handleCancel(e) {
    this.state.visible = false
    this.setState(this.state);
  }
  updateHandler() {
    this.state.systemInfo = systemInfo
    this.setState(this.state)
  }

  render() {
    return (
      <div style={{
        height: 40,
        width: '100%'
      }}>
        <Button
          type='primary'
          onClick={this.showModal}
          style={{margin: 10}}>
          获取帮助
        </Button>
        <Modal title="详细信息"
          visible={this.state.visible}
          onOk={this.handleOk}
          onCancel={this.handleCancel}>
          <p>本机可用的IP</p>
          <span style={{whiteSpace: 'pre-wrap'}}>
            {JSON.stringify(this.state.systemInfo.map(s => s.address), null, 4)}
          </span>
        </Modal>
      </div>
    )
  }
}
