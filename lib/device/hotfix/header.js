import React from 'react'
import {Button} from 'antd'

class Header extends React.Component {

  render() {
    const {onHotfix, onClearHotfix} = this.props
    return (
      <div style={{
        display: 'flex',
        justifyContent: 'flex-end',
        alignItems: 'center',
        height: '100%'
      }}>
        <Button type='primary' onClick={onHotfix} style={{marginRight: 10}}>hotfix!</Button>
        <Button type='primary' onClick={onClearHotfix}>clear hotfix!</Button>
      </div>
    )
  }
}

export default Header
