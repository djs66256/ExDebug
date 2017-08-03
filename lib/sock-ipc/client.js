const {AppClient} = require('./lib/app-client')
const {Message} = require('./lib/message')

let client = new AppClient()
client.connect()
client.on('connect', ()=>{
  console.log('connect !!!!');
  setTimeout(function () {
    client.request('listdir', '6FD69F53-25B2-4526-81DB-4239209D6C85', (err, resp)=>{
      console.log('listdir: ', resp);
    })
    client.request('deviceList', '0', (err, resp) => {
      console.log('deviceList: ', resp);
    })
  }, 100);
})
client.on('register', ({deviceId, message}) => {
  console.log('register: ', deviceId, message);
})
