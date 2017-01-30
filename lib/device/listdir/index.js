import React from 'react'
//import FileColumn from './file-column'
import IPC from '../../ipc-request'

class Content extends React.Component {

  componentDidMount() {
    IPC.request({path:'listdir'}).then(data => {
      console.log('listdir: ', data);
    })
  }

  render() {
    return (
      <div style={{
        width: '100%',
        height: '100%',
        overflow: 'auto'
      }}>

      </div>
    )
  }
}

export default Content
