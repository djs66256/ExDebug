import React from 'react'
import {render} from 'react-dom'
import Content from './content'

const app = render(
  <Content />,
  document.getElementById('content')
)
