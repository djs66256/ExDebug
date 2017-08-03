const {Message} = require('./lib/message')

console.log();
let msg = Message.request({path: 'test/test'})
console.log('origin: ', msg);
console.log();
let proxy = msg.wrapProxyMessage()
console.log('proxy: ', proxy);
console.log();
let buf = proxy.getBuffer()
console.log('buffer: ', buf);
console.log();
let [len2, proxy2] = Message.readFromData(buf)
console.log('proxy2: ', proxy2);
console.log();
let msg2 = proxy2.unwrapProxyMessage()
console.log('after: ', msg2);
