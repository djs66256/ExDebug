import React from 'react'

class RunloopListComponent extends React.Component {
  constructor() {
    super()
    this.state = { data: [] }
  }

  updateData(data) {
    this.state.data = data
    this.setState(this.state)
  }

  render() {
    const {style} = this.props
    return (
      <div style={
        Object.assign({
          padding: '15px 20px',
          overflowY: 'auto'
        }, style)}>
      {
        (() => {
          let items = []
          for (var i = 0; i < this.state.data.length && i<100; i++) {
            let data = this.state.data[i]
            let color = ''
            if (data.duration < 0.1) {
              color = 'rgba(139, 195, 74, 0.56)'
            }
            else if (data.duration < 0.5) {
              color = 'rgba(255, 193, 7, 0.56)'
            }
            else {
              color = 'rgba(255, 87, 34, 0.56)'
            }
            items.push((<p key={i} style={{
              lineHeight: '20px',
              backgroundColor: color
            }}>
             RUNLOOP:  {data.duration}
             </p>))
          }
          return items
        })()
      }
      </div>
    )
  }
}

export default RunloopListComponent
