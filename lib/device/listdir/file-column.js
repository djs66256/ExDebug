import React from 'react'
import {Menu, Icon} from 'antd'

class FileColumn extends React.Component {

  constructor() {
    super()
    this.handleClick = this.handleClick.bind(this)
    this.state = {selectedKeys:[]}
  }

  handleClick({key}) {
    this.state.selectedKeys = key ? [key] : []
    this.setState(this.state)
    const {files, onSelectFile} = this.props
    onSelectFile && onSelectFile(files.find(f=>f.name===key))
  }

  render() {
    const {files, style} = this.props
    return (
      <Menu style={style}
        onClick={this.handleClick}
        selectedKeys={this.state.selectedKeys}
      >
      {
        files && files.map(f=>{
          return (
            <Menu.Item key={f.name}
              style={{
                height: 20,
                lineHeight: '20px',
                padding: '0 10px'
              }}>
              <Icon type={f.isDirectory ? 'folder' : 'file'}/>
              {f.name}
            </Menu.Item>
          )
        })
      }
      </Menu>
    )
  }
}

export default FileColumn
