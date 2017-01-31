/**
 我们的首页，列了所有曾经连接过我们的手机
*/

import React from 'react'
import {render} from 'react-dom'

import Content from './components/content'

const app = render(
  <Content />,
  document.getElementById('content')
)
