import React from 'react'
import {Layout, Menu, Icon} from 'antd'
import Logger from './logger/logger'

let menus = [
  {
    key: 'home',
    icon: 'home',
    title: '首页',
    content: (<p>todo......... </p>)
  },
  {
    key: 'request',
    icon: 'chrome',
    title: '请求',
    content: (<p>Request doto....</p>)
  },
  {
    key: 'stat',
    icon: 'tag',
    title: 'DA统计',
    content: (<p>DA todo...</p>)
  },
  {
    key: 'runloop',
    icon: 'camera',
    title: 'RUNLOOP',
    content: (<p>RUNLOOP todo...</p>)
  },
  {
    key: 'logger',
    icon: 'code',
    title: '命令行',
    content: (<Logger />)
  },
  {
    key: 'settings',
    icon: 'setting',
    title: '设置',
    content: (<p>Setting todo...</p>)
  }
]

class Content extends React.Component {
  constructor() {
    super()
    this.state = {
      collapsed: false,
      selectedMenu: menus[0]
    }
    this.onCollapse = this.onCollapse.bind(this)
    this.onSelectMenu = this.onSelectMenu.bind(this)
  }

  onCollapse() {
    // let newState = Object.assign({}, this.state)
    // newState.collapsed = !this.state.collapsed
    this.state.collapsed = !this.state.collapsed
    this.setState(this.state)
  }
  onSelectMenu(item) {
    let menu = menus.find(m=>m.key===item.key)
    if (menu) {
      // let newState = Object.assign({}, this.state)
      // newState.selectedMenu = menu
      // this.setState(newState)
      this.state.selectedMenu = menu
      this.setState(this.state)
    }
  }

  render() {
    console.log('rendering');
    return (
      <Layout style={{width:'100%', height:'100%'}}>
        <Layout.Sider
          collapsible
          collapsed={this.state.collapsed}
          onCollapse={this.onCollapse}
        >
          <div className="logo" />
          <Menu theme="dark" mode="inline"
            defaultSelectedKeys={[this.state.selectedMenu.key]}
            onSelect={this.onSelectMenu}>
          {
            menus.map(menu => {
              return (
                <Menu.Item key={menu.key}>
                  <Icon type={menu.icon} />
                  <span className="nav-text">{menu.title}</span>
                </Menu.Item>
              )
            })
          }
          </Menu>
        </Layout.Sider>
        <Layout.Content>
          {this.state.selectedMenu.content}
        </Layout.Content>
      </Layout>)
  }
}

export default Content
