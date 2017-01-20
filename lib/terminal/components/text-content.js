import React from 'react'
import Component from '../component'

class TextLine extends Component {

  template(css) {
    return (
      <p><span>{this.props.text}</span></p>
    )
  }
}

export default class TextContent extends Component {

    componentDidUpdate() {
        document.body.scrollTop = this.refs.content.scrollHeight;
    }

  template(css) {
    const {texts, className} = this.props
    if (!texts) return null
    return (
      <div ref='content' className={className}>{
        texts.map(text => {
          return (<TextLine text={text}/>)
        })
    }
    <div ref='lastLine'></div>
    </div>
    )
  }
}
