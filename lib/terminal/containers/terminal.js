import React from 'react'
import Component from '../component'
import CmdInput from './cmd-input'
import TextContent from './text-content'

export default class Terminal extends Component {

  template(css) {
    return (
      <div>
      <TextContent className={css('content')}/>
      <div className={css('input')}>
      <CmdInput />
      </div>
      </div>
    )
  }

  styles() {
    return {
      content: {
        margin: '0 10px 40px 10px',
        'overflow-y': "scroll"
      },
      input: {
        position: 'fixed',
        left: 0,
        right: 0,
        bottom: 0,
        height: '40px',
        'background-color': 'gray'
      }
    }
  }
}
