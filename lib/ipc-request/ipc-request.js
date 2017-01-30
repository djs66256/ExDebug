import {ipcRenderer} from 'electron'

let requests = []
let registers = []

function findRequest(id, path) {
  for (let req of requests) {
    if (req.id === id && req.path === path) {
      return req
    }
  }
  return req
}

function requestTimeout(reqObj) {

}

function request(req) {
  return new Promise((resolve, reject) => {
    ipcRenderer.send('request', req)

    let reqObj = Object.assign({}, req)
    reqObj.timeout = setTimeout(function () {
      requests = requests.filter(r => r!==reqObj)
      reject(new Error('Request timeout'))
    }, req.timeout || 30000)
    reqObj.resovle = o=>{
      reqObj.timeout.close()
      requests = requests.filter(r => r!==reqObj)
      resovle(o)
    }
    reqObj.reject = o=>{
      reqObj.timeout.close()
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
  let reqObj = findRequest(response)
  if (reqObj) {
    if (error) {
      reqObj.reject(new Error(error))
    }
    else {
      reqObj.resovle(response.body)
    }
  }
})

ipcRenderer.on('register', (sender, {response}) => {
  let regObj = findRegisterByPath(response.path)
  regObj.callbacks.forEach(cb=>{
    cb(response.body)
  })
})

export {request, register, unregister}
