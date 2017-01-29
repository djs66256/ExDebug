import React from 'react'
import {Input} from 'antd'

class Footer extends React.Component {
  render() {
    return(
      <div style={{
        padding: '0 20px',
        height: 40, width: '100%',
        lineHeight: '40px'
      }}>
        <Input placeholder='cmd' />
      </div>
    )
  }
}

export default Footer
