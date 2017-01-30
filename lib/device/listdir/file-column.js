import React from 'react'

class FileColumn extends React.Component {

  render() {
    const {files} = this.props
    return (
      <div style={{
        // width: 80,
        height: '100%',
        overflow: 'auto'
      }}>
      {
        files && files.map(f=>{

        })
      }
      </div>
    )
  }
}

export default FileColumn
