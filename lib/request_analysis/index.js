import React from 'react'
import {render} from 'react-dom'
import {ipcRenderer} from 'electron'
import Duration from './duration'
import DataSize from './data-size'
import Total from './total'

ipcRenderer.on('requests', (event, requests) => {
  console.log('requests: ', requests);
  let style = {
    width: 320,
    height: 320
  }
  let app = render(
    <div style={{
      display: 'flex',
      flexDirection: 'row',
      flexWrap: 'wrap',
      alignItems: 'top'
    }}>
      <Total requests={requests} style={style} />
      <Duration requests={requests} style={style}/>
      <DataSize requests={requests} style={style}/>
    </div>,
    document.getElementById('content')
  )
})
