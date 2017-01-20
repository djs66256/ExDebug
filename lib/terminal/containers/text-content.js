import React from 'react'
import Component from '../component'
import TextContent from '../components/text-content'
import {connect} from 'react-redux'

class TextContentContainer extends Component {
  render() {
    return (
      <TextContent {...this.props} />
    )
  }
}

export default connect(
  state => {
    console.log('text container: ', state);
    return {
      texts: state.textContent
    }
  },
  dispatch => {
    return {

    }
  }
)(TextContentContainer)
