import React from 'react'
import {render} from 'react-dom'

import Content from './components/content'

const app = render(
  <Content />,
  document.getElementById('content')
)
