import React from 'react'
import Component from '../component'

export default class CmdInput extends Component {

  constructor() {
    super()
    this.handleChange = this.handleChange.bind(this)
    this.handleSend = this.handleSend.bind(this)
    this.state = {}
  }

  handleChange(e) {
    this.setState({cmd: e.target.value})
  }

  handleSend(e) {
    if (e.keyCode == '\n'.codePointAt(0) || e.keyCode == '\r'.codePointAt(0)) {
      const {sendData} = this.props
      if (sendData && this.state.cmd) {
        sendData(this.state.cmd)
      }
    }
  }

  template(css) {
    return (
      <input type='text' name='cmd' value={this.state.cmd || ""} className={css('fill')} onChange={this.handleChange} onKeyUp={this.handleSend}/>
    )
  }

  styles() {
    return {
      fill: {
        width: '100%',
        height: '100%'
      }
    }
  }

}
