import React from 'react'
import echarts from 'echarts'

class EChart extends React.Component {

  setOption(option) {
    if (this.echart && option) {
      this.echart.setOption(option)
    }
    console.log('option: ', option);
  }

  componentDidMount() {
    this.echart = echarts.init(this.refs.content)
    const {option} = this.props
    if (this.echart && option) {
      this.echart.setOption(option);
    }
  }

  render() {
    const {style, option} = this.props
    return (
      <div ref='content' style={Object.assign({
        width: '100%',
        height: 200,
        backgroundColor: 'gray'
      }, style)}>
      </div>
    )
  }
}

export default EChart
