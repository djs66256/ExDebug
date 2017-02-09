import React from 'react'
import {Layout, Input, message} from 'antd'
import Header from './header'
import IPC from '../../ipc-request'
import AceEditor from 'react-ace'

import 'brace/mode/java';
import 'brace/theme/monokai';

let HotfixCode = null

class Hotfix extends React.Component {

  constructor() {
    super()
    this.onHotfix = this.onHotfix.bind(this)
    this.onClearHotfix = this.onClearHotfix.bind(this)
    this.onChange = this.onChange.bind(this)
  }

  onChange(code) {
      HotfixCode = code
  }

  onPaste(code) {

  }

  onCopy(code) {

  }

  onHotfix() {
    if (HotfixCode) {
        IPC.request({path:'hotfix/run', body: HotfixCode}).then((resp)=>{
          message.info(resp.message)
        })
    }
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
        <AceEditor
          mode="javascript"
          theme="monokai"
          onChange={this.onChange}
          onPaste={this.onPaste}
          onCopy={this.onCopy}
          name="UNIQUE_ID_OF_DIV"
          editorProps={{$blockScrolling: true}}
          ref='content'
          style={{
            width: '100%',
            height: '100%',
            // fontFamily: 'monospace',
            fontSize: 14,
            // whiteSpace: 'pre-wrap',
            // fontWeight: 800,
            padding: 10
          }}
          placeholder='输入代码...'>
        </AceEditor>
      </Layout>
    )
  }
}

export default Hotfix
