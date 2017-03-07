import React from 'react'
import {Icon, Button, Message} from 'antd'
const {remote} = require('electron')
const {dialog} = remote
import IPC from '../../ipc-request'
import path from 'path'
import fs from 'fs'

class FileInfo extends React.Component {

  constructor() {
    super()
    this.handleDownload = this.handleDownload.bind(this)
  }

  handleDownload() {
    dialog.showOpenDialog(remote.getCurrentWindow(), {properties: ['openDirectory'], buttonLabel: '保存'}, (dirs) => {
      if (dirs.length > 0) {
        const {file} = this.props
        const tpath = path.join(dirs[0], file.name)
        const rpath = file.getFullPath()
        IPC.file(rpath).then(data => {
          fs.writeFile(tpath, data, (err) => err && Message.error(err.message))
        }).catch(e => Message.error(e.message))
      }
    })
  }

  render() {
    const {style, file} = this.props
    return (
      <div style={Object.assign({}, style, {
        width: 400,
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: 'white'
      })}>
        <div style={{
          width: '100%',
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'center',
          alignItems: 'center'
        }}>
          <Icon type='file' style={{fontSize: 120}}/>
          <div style={{
            width: '100%',
            fontSize: 14,
            justifyContent: 'center'
          }}>
            <p style={{
              padding: '20px 40px 0 40px',
              textAlign: 'center'
            }}>{file.name}</p>
          </div>
          <div style={{
            display: 'flex',
            flexDirection: 'column',
            justifyContent: 'center',
            alignItems: 'left',
            padding: '20px 40px 0 40px'
          }}>
            <p>创建时间：{file.createTime}</p>
            <p>修改时间：{file.modifyTime}</p>
            <p>文件大小：{file.fileSize}</p>
          </div>
          <Button
            onClick={this.handleDownload}
            style={{marginTop: 10}}
          >Download</Button>
        </div>
      </div>
    )
  }
}

export default FileInfo
