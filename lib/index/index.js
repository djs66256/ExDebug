import React from 'react'
import {render} from 'react-dom'
import {Provider} from 'react-redux'

import Content from './containers/content'
import store from './store'

const app = render(
  <Provider store={store}>
  <Content />
  </Provider>,
  document.getElementById('content')
)

import {connected, initial} from './actions/device'
import {updateSystemInfo} from './actions/sys-info'
import {ipcRenderer} from 'electron'
ipcRenderer.on('addDevice', (sender, device) => {
  connected(store.dispatch, device)
})

ipcRenderer.on('deviceList', (sender, devices) => {
  initial(store.dispatch, devices)
})

ipcRenderer.on('systemInfo', (sender, data) => {
  console.log('system info: ', data);
  updateSystemInfo(store.dispatch, data)
})
