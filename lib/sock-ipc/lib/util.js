const fs = require('fs')
const path = require('path')

const mkdirs_c = function(dirpath, mode, callback) {
  fs.exists(dirpath, function(exists) {
    if(exists) {
      callback(dirpath)
    } else {
      //尝试创建父目录，然后再创建当前目录
      mkdirs_c(path.dirname(dirpath), mode, function(err){
        fs.mkdir(dirpath, mode, callback)
      });
    }
  });
}

const mkdirs = (dirpath, mode) => {
  return new Promise((resovle, reject) => {
    mkdirs_c(dirpath, mode, () => {
      resovle(dirpath)
    })
  })
}



module.exports = {mkdirs}
