import React from 'react'
import {Icon} from 'antd'

class FileInfo extends React.Component {

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
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'center',
          alignItems: 'center'
        }}>
          <Icon type='file' style={{fontSize: 120}}/>
          <div style={{
            display: 'flex',
            flexDirection: 'column',
            justifyContent: 'center',
            alignItems: 'left',
            paddingTop: 20
          }}>
            <p>创建时间：{file.createTime}</p>
            <p>修改时间：{file.modifyTime}</p>
            <p>文件大小：{file.fileSize}</p>
          </div>
        </div>
      </div>
    )
  }
}

export default FileInfo
