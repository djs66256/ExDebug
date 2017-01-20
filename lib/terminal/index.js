import React from 'react'
import { Provider } from 'react-redux'
import { render } from 'react-dom'

import { store } from './store'
import Terminal from './containers/terminal'

render( <Provider store = { store } >
    <Terminal />
    </Provider>,
    document.getElementById('content')
)