/**
 封装了IPC，使用起来和普通的request/register一样了
*/

import {ipcRenderer} from 'electron'
import crypto from 'crypto'

const md5 = (str) => {
  var md5sum = crypto.createHash('md5')
  md5sum.update(str)
  let ret = md5sum.digest('hex')
  return ret
}

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

function request(params) {
  return new Promise((resolve, reject) => {
    let req = {}
    if (typeof params === 'string') {
      req.path = params
    }
    else {
      req = params
    }
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

function file(path) {
  return new Promise((resolve, reject) => {
    request({path: `fileinfo${path}`}).then(info => {
      let url = `file${path}`
      fileWithOffsetAndLength({path: url}).then(data => {
        if (data.length == info.fileSize) {
          let md = md5(data)
          if (md === info.md5) {
            return data
          }
        }
        return new Error('数据错误');
      })
    }).catch(reject)
  })
}

function fileWithOffsetAndLength({path, offset=0, length=100*1024}, buffer) {
    return new Promise((resolve, reject) => {
        request({path, head: {offset, length}}).then(data => {
            if (buffer) {
                return Buffer.concat([buffer, data])
            }
            else {
                return data
            }
        }).then(data => {
            if (data.length < offset+length) {
                resolve(data)
            }
            else {
                fileWithOffsetAndLength({path, offset:(offset+length)}, data).then(resolve).catch(reject)
            }
        }).catch(e => reject(e))
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

ipcRenderer.on('request', (sender, data) => {
console.log('request: ', data.response);
  let reqObj = findRequest(data.request.id, data.request.path)
  if (reqObj) {
    if (data.error) {
      reqObj.reject(new Error(error))
    }
    else {
      reqObj.resolve(data.response.body)
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

export {request, register, unregister, file}
