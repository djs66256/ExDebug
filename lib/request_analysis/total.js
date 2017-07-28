import React from 'react'

export default class TotalComponent extends React.Component {

  constructor() {
    super()
    this.state = {totalSize: 0, speed: 0}
  }

  componentDidMount() {
    const {requests} = this.props

    let totalSize = 0
    let totalTime = 0
    let speed = 0
    requests && requests.forEach(req => {
      totalSize += req.downloadByteCount + req.uploadByteCount
      totalTime += req.endTime - req.startTime
    })
    speed = totalSize/1024/totalTime
    this.setState({
      totalSize, speed
    })
  }

  render() {
    const {style} = this.props
    return (
      <div style={style}>
        <p>数据总量：{(this.state.totalSize / 1024 / 1024).toFixed(2)}MB</p>
        <p>平均速度：{this.state.speed.toFixed(2)}kB/s</p>
      </div>
    )
  }
}
