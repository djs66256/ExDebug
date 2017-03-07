import React from 'react'
import path from 'path'
import url from 'url'
import Request from './data'
import {Menu, Icon, Button, Layout, Modal} from 'antd'
const {BrowserWindow} = require('electron').remote

class RequestComponent extends React.Component {

  constructor() {
    super()
    this.onSelectRequest = this.onSelectRequest.bind(this)
    this.onDeselectRequest = this.onDeselectRequest.bind(this)
    this.onClear = this.onClear.bind(this)
    this.onBeginRecord = this.onBeginRecord.bind(this)
    this.onStopRecord = this.onStopRecord.bind(this)
    this.onAnalysis = this.onAnalysis.bind(this)
    this.updateData = this.updateData.bind(this)
    this.recordData = this.recordData.bind(this)

    this.state = {
      data: Request.data,
      selectedRequest: null
    }
  }

  componentDidMount() {
    Request.on('changed', this.updateData)
    Request.on('request', this.recordData)
  }
  componentDidUnmount() {
    Request.removeListener(this.updateData)
    Request.removeListener(this.recordData)
  }

  updateData(data) {
    this.state.data = data
    this.setState(this.state)
  }
  recordData(data) {
    if (this.recording && this.record) {
      this.record.push(data)
    }
  }

  onSelectRequest({key}) {
    if (this.state.data.length > key) {
      this.state.selectedKeys = [key]
      this.state.selectedRequest = this.state.data[key]
      this.setState(this.state)
    }
  }

  onDeselectRequest() {
    this.state.selectedKeys = []
    this.state.selectedRequest = null
    this.setState(this.state)
  }

  onClear() {
    Request.clear()
    this.state.selectedKeys = []
    this.state.selectedRequest = null
    this.state.data = Request.data
    this.setState(this.state)
  }

  onBeginRecord() {
    this.record = []
    this.recording = true
  }

  onStopRecord() {
    if (this.recording) {
      this.recording = false
    }
  }

  onAnalysis() {
    this.onStopRecord()
    this.openAnalysisWin()
  }

  openAnalysisWin() {
    let win = new BrowserWindow({width: 800, height: 600})
    const analysisUrl = url.format({
      pathname: path.join(__dirname, 'request_analysis.html'),
      protocol: 'file:',
      slashes: true
    })
    win.loadURL(analysisUrl)
    win.webContents.once('did-finish-load', () => {
      this.win.webContents.send('requests', this.recordData)
    })
  }

  render() {
    return (
      <Layout style={{
        height: '100%',
        width: '100%'
      }}>
        <Layout.Header style={{
          height: 40,
          padding: '0',
          margin: 0,
          lineHeight: '40px'
        }}>
          <Button type='primary' style={{marginLeft: 10}} onClick={this.onClear}>清除</Button>
          <Button type='primary' style={{marginLeft: 20}} onClick={this.onBeginRecord}>开始录制</Button>
          <Button type='primary' style={{marginLeft: 10}} onClick={this.onStopRecord}>停止录制</Button>
          <Button type='primary' style={{marginLeft: 10}} onClick={this.onAnalysis}>分析</Button>
        </Layout.Header>
        <div className='ant-layout-content' ref='content' style={{
          overflow:'auto'
        }}>
          <Menu
          selectedKeys={this.state.selectedKeys}
          onSelect={this.onSelectRequest}
          style={{
            width: '100%',
            height: '100%'
          }}>
          {
            this.state.data && this.state.data.map((req, index) => {
              return (
                <Menu.Item
                  style={{
                    height: 20,
                    width: '100%',
                    lineHeight: '20px',
                    padding: '0 10px'
                  }}
                  key={index}>
                    {req.url}
                </Menu.Item>)
            })
          }
          </Menu>
        </div>
        <Modal visible={!!this.state.selectedRequest}
        onOk={this.onDeselectRequest}
        onCancel={this.onDeselectRequest} >
        {
            this.state.selectedRequest && Object.keys(this.state.selectedRequest).map(key=>{
              return (<p>{key}: {this.state.selectedRequest[key]}</p>)
            })
        }
        </Modal>
      </Layout>
    )
  }

}

export default RequestComponent
