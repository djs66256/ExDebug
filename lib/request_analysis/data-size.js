import CircleGraphComponent from './circle-graph'

class DataSizeComponent extends CircleGraphComponent {

  componentDidMount() {
    super.componentDidMount()
    this.setTitle('数据量分布 kb')
    const {requests} = this.props
    if (requests) {
      let map = {}
      let sizeRange = [10, 100, 200, 500, 1000, 2000]
      for (var i = 0; i < requests.length; i++) {
        let req = requests[i]
        let size = (req.downloadByteCount + req.uploadByteCount)/1000.0
        this.mapSizeInRange(map, size, sizeRange)
      }
      let data = this.dataFromMap(map)
      this.updateData(data)
    }
  }

}

export default DataSizeComponent
