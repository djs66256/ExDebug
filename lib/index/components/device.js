import React from 'react'
import Component from '../component'

export default class Device extends Component {

  template(css) {
    const {device, onDoubleClick} = this.props
    return (
      <div className={css('item')} onDoubleClick={onDoubleClick(device)}>
      </div>
    )
  }

  styles() {
    return {
      'item': {
        width: '100px',
        height: '200px',
        float: 'left',
        margin: '10px',
        'background-color': 'red'
      }
    }
  }
}
