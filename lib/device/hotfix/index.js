import React from 'react'
import {Layout, Input, message} from 'antd'
import Header from './header'
import IPC from '../../ipc-request'

class Hotfix extends React.Component {

  constructor() {
    super()
    this.onHotfix = this.onHotfix.bind(this)
    this.onClearHotfix = this.onClearHotfix.bind(this)
  }

  onHotfix() {
    let value = this.refs.content.value
    IPC.request({path:'hotfix/run', body: value}).then((resp)=>{
      message.info(resp.message)
    })
  }

  onClearHotfix() {
    IPC.request('hotfix/clear').then((resp)=>{
      message.info(resp.message)
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
          padding: '0 20px',
          margin: 0,
          lineHeight: '40px'
        }}>
          <Header onHotfix={this.onHotfix} onClearHotfix={this.onClearHotfix}/>
        </Layout.Header>
        <textarea
          ref='content'
          style={{
            width: '100%',
            height: '100%',
            fontFamily: 'monospace',
            whiteSpace: 'pre-wrap',
            fontWeight: 800,
            padding: 10
          }}
          placeholder='输入代码...'>
        </textarea>
      </Layout>
    )
  }
}

export default Hotfix
