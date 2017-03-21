import CircleGraphComponent from './circle-graph'

class DurationComponent extends CircleGraphComponent {

  componentDidMount() {
    super.componentDidMount()
    this.setTitle('时长分布 s')
    const {requests} = this.props
    if (requests) {
      let map = {}
      let sizeRange = [0.100, 0.200, 0.500, 1.000, 1.500, 2.000]
      for (var i = 0; i < requests.length; i++) {
        let req = requests[i]
        let duration = (req.endTime - req.startTime)
        this.mapSizeInRange(map, duration, sizeRange)
      }
      let data = this.dataFromMap(map)
      this.updateData(data)
    }
  }

}

export default DurationComponent
