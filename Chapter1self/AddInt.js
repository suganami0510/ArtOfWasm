const fs = require("fs")

const bytes = fs.readFileSync(__dirname + '/Addint.wasm');
const value_1 = parseInt(process.argv[2]); // 第一引数
const value_2 = parseInt(process.argv[3]); // 第2引数

(async () => { // 3 プロミスオブジェクトが返されるまでなにか別の作業をしてよいと伝える。
  const obj = await WebAssembly.instantiate(new Uint8Array(bytes)); // 4 byteファイルをオブジェクト化 <WebAssemblyInstantiatedSource>
  let add_value = obj.instance.exports.AddInt(value_1, value_2);
  console.log(`${value_1} + ${value_2} = ${add_value}`);
})(); // IIFE(Immediately Invoked Function Expression: 即時実行関数)