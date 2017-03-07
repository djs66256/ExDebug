import React from 'react'
import {render} from 'react-dom'
import {ipcRenderer} from 'electron'
import Duration from './duration'

ipcRenderer.on('requests', (event, requests) => {
  console.log('requests: ', requests);
  let app = render(
    <div style={{
      display: 'flex',
      flexDirection: 'row',
      flexWrap: 'wrap',
      alignItems: 'top'
    }}>
      <Duration requests={requests} style={{
        width: 320,
        height: 320
      }}/>
    </div>,
    document.getElementById('content')
  )
})
