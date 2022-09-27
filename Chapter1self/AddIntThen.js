const fs = require("fs")

const bytes = fs.readFileSync(__dirname + '/Addint.wasm');
const value_1 = parseInt(process.argv[2]); // 第一引数
const value_2 = parseInt(process.argv[3]); // 第2引数

WebAssembly.instantiate(new Uint8Array(bytes))
.then(obj => {
  let add_value = obj.instance.exports.AddInt(value_1, value_2);
  console.log(`${value_1} + ${value_2} = ${add_value}`);
})