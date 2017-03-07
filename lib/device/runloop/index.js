import React from 'react'
import RunloopData from './data'
import echarts from 'echarts'
import RunloopList from './runloop-list'

class RunloopComponent extends React.Component {
  constructor() {
    super()
    this.state = {data:[]}
    this.updateData = this.updateData.bind(this)
  }

  componentDidMount() {
    this.state.data = RunloopData.data
    this.refs.runloopList.updateData(this.state.data)

    RunloopData.on('changed', this.updateData)
    if (!this.graph_percentage) {
      this.graph_percentage = echarts.init(this.refs.graph_percentage)
      let option = {
          title : {
              text: 'RUNLOOP',
              x: 'center',
              y: 20
          },
          tooltip : {
              trigger: 'item',
              formatter: "{a} <br/>{b} : {c} ({d}%)"
          },
          // legend: {
          //     orient: 'vertical',
          //     left: 'left',
          //     data: ['直接访问','邮件营销','联盟广告','视频广告','搜索引擎']
          // },
          series : [
              {
                  name: '访问来源',
                  type: 'pie',
                  radius : '60%',
                  center: ['50%', '50%'],
                  data:[
                      // {value:335, name:'直接访问'},
                      // {value:310, name:'邮件营销'},
                      // {value:234, name:'联盟广告'},
                      // {value:135, name:'视频广告'},
                      // {value:1548, name:'搜索引擎'}
                  ],
                  itemStyle: {
                      emphasis: {
                          shadowBlur: 10,
                          shadowOffsetX: 0,
                          shadowColor: 'rgba(0, 0, 0, 0.5)'
                      }
                  }
              }
          ]
      };
      this.graph_percentage.setOption(option)
    }
    this.graph_percentage.setOption({series: [{data:RunloopData.getChartData()}]})
  }

  componentWillUnmount() {
    RunloopData.removeListener('changed', this.updateData)
  }

  updateData(data) {
    this.state.data = data
    // this.setState(this.state)
    this.refs.runloopList.updateData(data)
    let datas = RunloopData.getChartData()
    this.graph_percentage.setOption({series: [{data:datas}]})
  }

  render() {
    return (
      <div style={{
        width: '100%',
        height: '100%',
        display: 'flex',
      }}>
        <div ref='graph_percentage' style={{
          height: '400px',
          width: '400px',
          flexShrink: 0,
          flexGrow: 0
        }}> </div>
        <div style={{
          backgroundColor: 'rgba(0,0,0,0.2)',
          flexGrow: 0,
          flexShrink: 0,
          height: '100%',
          width: 1
        }} />
        <RunloopList
        ref='runloopList'
        style={{
          height: '100%',
          flexShrink: 1,
          flexGrow: 1
        }} />
      </div>
    )
  }
}

export default RunloopComponent
