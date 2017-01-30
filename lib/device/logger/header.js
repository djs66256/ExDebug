import React from 'react'
import {Dropdown, Menu, Button, Icon} from 'antd'

function stringFilter(str) {
  return log => !!log.match(str)
}

const filters = [
  {
    title: 'LEVEL',
    filters: [
      {
        title: 'ALL'
      },
      {
        title: 'DEBUG',
        filter: stringFilter(/DEBUG|INFO|WARNING|ERROR/)
      },
      {
        title: 'INFO',
        filter: stringFilter(/INFO|WARNING|ERROR/)
      },
      {
        title: 'WARNING',
        filter: stringFilter(/WARNING|ERROR/)
      },
      {
        title: 'ERROR',
        filter: stringFilter(/ERROR/)
      }
    ]
  },
  {
    title: '类别',
    filters: [
      {
        title: 'All'
      },
      {
        title: 'STAT',
        filter: stringFilter(/STAT/)
      },
      {
        title: 'RUNLOOP',
        filter: stringFilter(/RUNLOOP/)
      },
      {
        title: 'RESPONSE',
        filter: stringFilter(/RESPONSE/)
      },
      {
        title: 'IMAGE',
        filter: stringFilter(/IMAGE/)
      }
    ]
  }
]


class Header extends React.Component {
  constructor() {
    super()
    this.state = {filters:filters.map(f=>Object.assign({},f))}
  }

  render() {
    const {onFiltersChange} = this.props
    return(
      <div style={{height: '100%', width: '100%'}}>
      <span style={{marginRight: 10, color: 'white'}}>过滤器：</span>
      {
        this.state.filters.map(f=> {
          return (
            <div key={f.title} style={{display: 'inline'}}>
              <span style={{
                color: 'white'
              }}>{f.title}</span>
              <Dropdown
                overlay={(
                  <Menu onClick={({key})=>{
                      f.selectedTitle = key
                      let fo = f.filters.find(f2=>f2.title===key)
                      f.selectedFilter = fo && fo.filter
                      this.setState(this.state)
                      onFiltersChange && onFiltersChange(this.state.filters.filter(f=>!!f.selectedFilter).map(f=>f.selectedFilter))
                    }}
                    selectedKeys={f.selectedTitle && [f.selectedTitle]}
                    filterObj={f}>
                    {
                      f.filters.map(f2=>{
                        return (
                            <Menu.Item key={f2.title} filter={f2.filter}>{f2.title}</Menu.Item>
                        )
                      })
                    }
                  </Menu>
                )}>
                <Button type="default" style={{ marginLeft: 8, marginRight: 20 }}>
                  {f.selectedTitle || f.title} <Icon type="down" />
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
