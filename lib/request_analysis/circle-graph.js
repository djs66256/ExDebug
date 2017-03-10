import React from 'react'
import {Card} from 'antd'
import echarts from 'echarts'

class CircleGraphComponent extends React.Component {

  componentDidMount() {
    this.chart = echarts.init(this.refs.content)
    let option = {
        title : {
            text: '',
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
                name: '-',
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
    this.chart.setOption(option)
  }

  setTitle(title) {
    this.chart.setOption({
      title: {
        text: title
      }
    })
  }

  updateData(data) {
    this.chart.setOption({series: [{ data }]})
  }

  mapSizeInRange(map, size, sizeRange) {
    if (size < sizeRange[sizeRange.length - 1]) {
      for (var i = 0; i < sizeRange.length; i++) {
        let range = sizeRange[i]
        if (size < range) {
          if (i == 0) {
            let key = '0-'+range
            map[key] ? map[key]++ : map[key]=1
          }
          else {
            let key = sizeRange[i-1]+'-'+range
            map[key] ? map[key]++ : map[key]=1
          }
          return map
        }
      }
    }
    else {
      let max = sizeRange[sizeRange.length - 1]
      map[max+'+'] ? map[max+'+']++ : map[max+'+']=1
    }
    return map
  }

  dataFromMap(map) {
    return Object.keys(map).map(key => {
      return {name: key, value: map[key]}
    })
  }

  render() {
    const {style} = this.props
    return (
      <div style={Object.assign({
        background: 'white',
        borderRadius: '4px',
        transition: 'all .3s',
        border: '1px solid #e9e9e9'
      }, style)}>
        <div ref='content' style={{
          width: '100%',
          height: '100%'
        }}>
        </div>
      </div>
    )
  }

}

export default CircleGraphComponent
