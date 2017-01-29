import React from 'react'
import Component from '../component'
import {Card, Icon, Modal} from 'antd'

export default class Device extends Component {

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
    const {device, onDoubleClick} = this.props
    return (
      <Card title={device.deviceModel}
        extra={
          <div style={{fontSize: '15px'}}>
            <Icon type="exclamation-circle"
              style={device.connected ? {color: 'green'} : {}} />
            <a href="#" style={{marginLeft: '5px'}} onClick={this.showModal}>More</a>
            <Modal title="详细信息"
              visible={this.state.visible}
              onOk={this.handleOk}
              onCancel={this.handleCancel}>
              <span style={{whiteSpace: 'pre-wrap'}}>
                {JSON.stringify(device, null, 4)}
              </span>
            </Modal>
          </div>
        }
        style={{
          width: 300,
          margin: 10,
          float: 'left'
        }}
        onDoubleClick={onDoubleClick(device)}>
        <p>{`${device.os} ${device.osVersion}`}</p>
        <p>{`Build: ${device.buildNumber}`}</p>
        <p>{`App Ver: ${device.appVersion}`}</p>
        <p>{`Protocol Ver: ${device.protocolVersion}`}</p>
        <p>{device.resolution}</p>
      </Card>
    )
  }

  styles() {
    return {
      'connected': {
        width: '100px',
        height: '200px',
        float: 'left',
        margin: '10px',
        'background-color': 'red'
      }
    }
  }
}
