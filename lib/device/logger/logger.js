import React from 'react'
import Terminal from './terminal'
import Header from './header'
import Footer from './footer'
import {Layout} from 'antd'

class Logger extends React.Component {

  constructor() {
    super()
    this.componentDidUpdate = this.componentDidUpdate.bind(this)
  }

  componentDidUpdate() {
    console.log(this.refs.content, this.refs.content.scrollTop, this.refs.content.scrollHeight);
    this.refs.content.scrollTop = this.refs.content.scrollHeight;
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
          <Header />
        </Layout.Header>
        <div className='ant-layout-content' ref='content' style={{
          overflow:'auto',
          backgroundColor:'rgba(0, 0, 0, 0.85)'
        }}>
          <Terminal scrollTop={this.componentDidUpdate}/>
        </div>
        <Layout.Footer style={{
          height: 40,
          margin: 0,
          padding: 0
        }}>
          <Footer />
        </Layout.Footer>
      </Layout>
    )
  }

}

export default Logger
