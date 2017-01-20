import React from 'react'
import Component from '../component'

export default class SystemInfo extends Component {

  template(css) {
    const {systemInfo} = this.props || {}
    if (systemInfo) {
      return (
        <div>
        {
          systemInfo.map(({address}) => {
            return (<p>ip: {address}</p>)
          })
        }
        </div>
      )
    }
    return null
  }
}
