import CircleGraphComponent from './circle-graph'

class DurationComponent extends CircleGraphComponent {

  componentDidMount() {
    super.componentDidMount()
    this.setTitle('时长分布 ms')
    const {requests} = this.props
    if (requests) {
      let map = {}
      for (var i = 0; i < requests.length; i++) {
        let req = requests[i]
        let duration = (req.endTime - req.startTime)*1000
        const maxDuration = 2000
        if (duration < maxDuration) {
          for (var j = 100; j < maxDuration; j += 100) {
            if (duration < j) {
              map[j] ? map[j]++ : map[j]=1
              break
            }
          }
        }
        else {
          map[maxDuration+'+'] ? map[maxDuration+'+']++ : map[maxDuration+'+']=1
        }
      }
      let data = Object.keys(map).map(key => {
        return {name: key.toString(), value: map[key]}
      })
      this.updateData(data)
    }
  }

}

export default DurationComponent
