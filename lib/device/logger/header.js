import React from 'react'
import {Dropdown, Menu, Button, Icon} from 'antd'


function handleMenuClick(e) {
  console.log('click left button', e);
}

const menu = (
  <Menu onClick={handleMenuClick}>
    <Menu.Item key="1">1st menu item</Menu.Item>
    <Menu.Item key="2">2nd menu item</Menu.Item>
    <Menu.Item key="3">3d menu item</Menu.Item>
  </Menu>
);

const filters = [
  {
    title: 'LEVEL',
    filters: [
      {
        title: 'DEBUG'
      },
      {
        title: 'INFO'
      }
    ]
  },
  {
    title: '类别',
    filters: [
      {
        title: 'STAT'
      },
      {
        title: 'RUNLOOP'
      }
    ]
  }
]


class Header extends React.Component {
  render() {
    return(
      <div style={{height: '100%', width: '100%'}}>
      {
        filters.map(f=> {
          return (
            <div key={f.title} style={{display: 'inline'}}>
              <span style={{
                color: 'white'
              }}>{f.title}</span>
              <Dropdown
                overlay={(
                  <Menu onClick={handleMenuClick}>
                    {
                      f.filters.map(f2=>{
                        return (
                            <Menu.Item key={f2.title}>{f2.title}</Menu.Item>
                        )
                      })
                    }
                  </Menu>
                )}>
                <Button type="default" style={{ marginLeft: 8, marginRight: 20 }}>
                  {f.title} <Icon type="down" />
                </Button>
              </Dropdown>
            </div>
          )
        })
      }
      </div>
    )
  }
}

export default Header
