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
ipcRenderer.on('add-device', (sender, device) => {
  connected(store.dispatch, device)
})

ipcRenderer.on('device-list', (sender, devices) => {
  initial(store.dispatch, devices)
})

ipcRenderer.on('system-info', (sender, data) => {
  console.log('system info: ', data);
  updateSystemInfo(store.dispatch, data)
})
