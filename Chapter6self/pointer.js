const fs = require('fs');
const bytes = fs.readFileSync(__dirname + '/pointer.wasm');
const memory = new WebAssembly.Memory({ initial: 1, maximum: 4 }); // 1ページの線形メモリ確保、最大maximum4まで線形メモリのサイズを増やす可能性があること。

const importObject = {
  env: {
    mem: memory,
  },
};

(async () => {
  let obj = await WebAssembly.instantiate(new Uint8Array(bytes), importObject);

  let pointer_value = obj.instance.exports.get_ptr();
  console.log(`pointer_values=${pointer_value}`);
})();
