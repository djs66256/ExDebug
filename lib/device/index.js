/**
 打开后的页面，所有详细功能在这里
*/

import React from 'react'
import {render} from 'react-dom'
import Content from './content'

const app = render(
  <Content />,
  document.getElementById('content')
)
