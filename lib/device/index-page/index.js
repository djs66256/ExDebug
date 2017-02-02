import React from 'react'
import EChart from './echart'
import IPC from '../../ipc-request'

let maxLength = 120
let sysInfoUpdateHandler = null
let availableMemory = []
let usedMemory = []
let cpu = []
let firstTime = null

IPC.register('systemInfo', (data)=>{
  let time = new Date(data.time)
  let xValue = (firstTime && Math.round(data.time - firstTime)) || 0
  usedMemory.push([xValue, data.usedMemory])
  availableMemory.push([xValue, data.availableMemory])
  cpu.push([xValue, data.cpuUsage])
  if (usedMemory.length > maxLength) {
    usedMemory.shift()
    availableMemory.shift()
    cpu.shift()
  }

  if (!firstTime) firstTime = data.time
  if (sysInfoUpdateHandler) sysInfoUpdateHandler()
})

let fps = []
let fpsCount = 0
let fpsUpdateHandler = null
let fpsMaxCount = 60*30
IPC.register('fps', (data) => {
  for (let item of data.fps) {
    fps.push([fpsCount, item])
    fpsCount++
    if (fps.length > maxLength * 60) {
      fps.shift()
    }
  }
  fpsUpdateHandler && fpsUpdateHandler()
})

class Index extends React.Component {

  constructor() {
    super()
    this.sysInfoUpdateHandler = this.sysInfoUpdateHandler.bind(this)
    this.fpsUpdateHandler = this.fpsUpdateHandler.bind(this)
  }

  componentDidMount() {
    sysInfoUpdateHandler = this.sysInfoUpdateHandler
    fpsUpdateHandler = this.fpsUpdateHandler
  }

  componentWillUnmount() {
    sysInfoUpdateHandler = null
    fpsUpdateHandler = null
  }

  sysInfoUpdateHandler() {
    this.refs.memoryOptionChart.setOption({
      series: [
        { data: usedMemory },
        { data: availableMemory }
      ]
    })
    this.refs.cpuOptionChart.setOption({
      series: [{
        data: cpu
      }]
    })
  }

  fpsUpdateHandler() {
    this.refs.fpsOptionChart.setOption({
      series: [{
        data: fps
      }]
    })
  }

  render() {
    // let data=[[11,2],[12,3],[13,4]]
    let baseOption = {
      grid: {
        top: 40,
        bottom: 20,
        backgroundColor: 'white'
      },
      xAxis: {
        type: 'value',
        min: 'dataMin',
        max: 'dataMax'
      },
      yAxis: {
        type: 'value',
        splitLine: {}
      },
      // tooltip: {
      //   trigger: 'axis',
      //   axisPointer: {
      //     axis: 'y'
      //   }
      // },
    }

    let memoryOption = Object.assign({}, baseOption, {
      title: {
        text: '内存(MB)',
        left: 40
      },
      legend: {
        data: ['已用', '空闲']
      },
      series: [{
        name: '已用',
        type: 'line',
        showSymbol: false,
        data: usedMemory
      },
      {
        name: '空闲',
        type: 'line',
        showSymbol: false,
        data: availableMemory
      }]
    })
    let cpuOption = Object.assign({}, baseOption, {
      title: {
        text: 'CPU使用率%',
        left: 40
      },
      series: [{
        name: 'CPU',
        type: 'line',
        showSymbol: false,
        data: cpu
      }]
    })
    let fpsOption = Object.assign({}, baseOption, {
      title: {
        text: 'FPS',
        left: 40
      },
      series: [{
        name: 'FPS',
        type: 'line',
        showSymbol: false,
        data: fps
      }]
    })
    let style = {
      flexShrink: 0,
      width: '100%',
      height: 180,
      paddingTop: 20
    }
    return (
      <div style={{
        width: '100%',
        height: '100%',
        overflow: 'auto',
        display: 'flex',
        flexDirection: 'column',
      }}>
        <EChart ref='memoryOptionChart'
          option={memoryOption}
          style={style}/>
        <EChart ref='cpuOptionChart'
          option={cpuOption}
          style={style}/>
        <EChart ref='fpsOptionChart'
          option={fpsOption}
          style={style}/>
      </div>
    )
  }
}

export default Index
