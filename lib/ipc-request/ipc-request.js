/**
 封装了IPC，使用起来和普通的request/register一样了
*/

import {ipcRenderer} from 'electron'

let requests = []
let id = 100
let registers = []

function findRequest(id, path) {
  for (let reqObj of requests) {
    if (reqObj.id === id && reqObj.path === path) {
      return reqObj
    }
  }
  return null
}

function request(req) {
  return new Promise((resolve, reject) => {
    id ++
    if (id>1000000) {
      id = 100
    }
    req.id = id
    ipcRenderer.send('request', req)

    let reqObj = Object.assign({}, req)
    reqObj.id = id
    reqObj.timeout = setTimeout(function () {
      requests = requests.filter(r => r!==reqObj)
      reject(new Error('Request timeout'))
    }, req.timeout || 30000)
    reqObj.resolve = o=>{
      clearTimeout(reqObj.timeout)
      requests = requests.filter(r => r!==reqObj)
      resolve(o)
    }
    reqObj.reject = o=>{
      clearTimeout(reqObj.timeout)
      requests = requests.filter(r => r!==reqObj)
      reject(o)
    }
    requests.push(reqObj)
  })
}

function findRegisterByPath(path) {
  for (let regObj of registers) {
    if (regObj.path === path) {
      return regObj
    }
  }
  return null
}

function register(path, callback) {
  if (!path || !callback) return
  let regObj = findRegisterByPath(path)
  if (!regObj) {
    regObj = {path, callbacks:[callback]}
    registers.push(regObj)
  }
  else {
    regObj.callbacks.push(callback)
  }
}

function unregister(path, callback) {
  if (!path || !callback) return
  let regObj = findRegisterByPath(path)
  if (regObj) {
    regObj.callbacks = regObj.callbacks.filter(cb=>cb!=callback)
  }
}

ipcRenderer.on('request', (sender, {response, error}) => {
console.log('request: ', response);
  let reqObj = findRequest(response.id, response.path)
  if (reqObj) {
    if (error) {
      reqObj.reject(new Error(error))
    }
    else {
      reqObj.resolve(response.body)
    }
  }
})

ipcRenderer.on('register', (sender, {response}) => {
console.log('register: ', response);
  let regObj = findRegisterByPath(response.path)
  regObj && regObj.callbacks.forEach(cb=>{
    cb(response.body)
  })
})

export {request, register, unregister}
