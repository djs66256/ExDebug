import React from 'react'
import Component from '../component'
import {Button, Modal} from 'antd'

export default class SystemInfo extends Component {

  constructor() {
    super()
    this.state = {visible: false}
    this.showModal = this.showModal.bind(this)
    this.handleOk = this.handleOk.bind(this)
    this.handleCancel = this.handleCancel.bind(this)
  }

  showModal() {
    this.setState({
      visible: true,
    });
  }
  handleOk() {
    this.setState({
      visible: false,
    });
  }
  handleCancel(e) {
    this.setState({
      visible: false,
    });
  }

  template(css) {
    const {systemInfo} = this.props || {}
    if (systemInfo) {
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
              {JSON.stringify(systemInfo.map(s => s.address), null, 4)}
            </span>
          </Modal>
        </div>
      )
    }
    return null
  }
}
