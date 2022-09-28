const fs = require('fs');
const bytes = fs.readFileSync(__dirname + '/func_perform.wasm');

let i = 0;
let importObject = {
  js: {
    external_call: function () {
      i++;
      return i;
    },
  },
};

(async () => {
  const obj = await WebAssembly.instantiate(
    new Uint8Array(bytes),
    importObject
  );

  // obj.instance.exportsからのwasm_callとjs_callの分割代入
  ({ wasm_call, js_call } = obj.instance.exports);

  let start = Date.now();
  // WebAssemblyモジュールからwasm_callを呼び出し
  wasm_call();
  let time = Date.now() - start;

  console.log('wasm_call time=' + time);

  start = Date.now();

  // WebAssemblyモジュールからjs_callを呼び出し
  js_call();
  time = Date.now() - start;
  console.log('js_call time=' + time);

  // やってみた結果
  // wasm_call time=7
  // js_call time=20 -> jsの外部関数を呼び出している分のオーバーヘッド
})();
