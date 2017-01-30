import React from 'react'
import {Layout} from 'antd'
import SystemInfo from './sys-info'
import Devices from './devices'

class Content extends React.Component {

  render() {
    return (
      <Layout style={{
        width: '100%',
        height: '100%'
      }}>
        <Layout.Header>
          <SystemInfo />
        </Layout.Header>
        <Layout.Content style={{
          width: '100%',
          height: '100%',
          padding: 10
        }}>
          <Devices />
        </Layout.Content>
      </Layout>
    )
  }
}

export default Content
