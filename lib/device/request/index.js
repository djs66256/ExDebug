import React from 'react'
import path from 'path'
import url from 'url'
import Request from './data'
import {Menu, Icon, Button, Layout, Modal} from 'antd'
const {BrowserWindow, getCurrentWebContents} = require('electron').remote

class RequestComponent extends React.Component {

  constructor() {
    super()
    this.onSelectRequest = this.onSelectRequest.bind(this)
    this.onDeselectRequest = this.onDeselectRequest.bind(this)
    this.onClear = this.onClear.bind(this)
    this.onRecord = this.onRecord.bind(this)
    this.onAnalysis = this.onAnalysis.bind(this)
    this.updateData = this.updateData.bind(this)
    this.recordData = this.recordData.bind(this)

    this.state = {
      data: Request.data,
      selectedRequest: null,
      record: {recording: false, data:[], title: '开始录制'}
    }
  }

  componentDidMount() {
    Request.on('changed', this.updateData)
    Request.on('request', this.recordData)
  }
  componentWillUnmount() {
    Request.removeListener('changed', this.updateData)
    Request.removeListener('request', this.recordData)
  }

  updateData(data) {
    this.state.data = data
    this.setState(this.state)
  }
  recordData(data) {
    if (this.state.record.recording) {
      this.state.record.data.push(data)
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

  onRecord() {
    if (this.state.record.recording) {
      if (this.state.record.data.length > 0) {
        this.openAnalysisWin(this.state.record.data)
      }
      this.state.record = {
        recording: false,
        data:this.state.record.data,
        title: '开始录制'
      }
    }
    else {
      this.state.record = {
        recording: true,
        data:[],
        title: '录制中...'
      }
    }
    this.setState(this.state)
  }

  onAnalysis() {
    this.openAnalysisWin(this.state.data)
  }

  openAnalysisWin(data) {
    let win = new BrowserWindow({width: 800, height: 600})
    const analysisUrl = url.resolve(getCurrentWebContents().getURL(), 'request_analysis.html')
    win.loadURL(analysisUrl)
    win.webContents.once('did-finish-load', () => {
      win.webContents.send('requests', data)
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
          <Button type='primary' style={{marginLeft: 20}} onClick={this.onRecord}>{this.state.record.title}</Button>
          <Button type='primary' style={{marginLeft: 10}} onClick={this.onAnalysis}>分析所有</Button>
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
