const fs = require('fs');
const export_bytes = fs.readFileSync(__dirname + '/table_export.wasm');
const test_bytes = fs.readFileSync(__dirname + '/table_test.wasm');

let i = 0;
let increment = () => {
  i++;
  return i;
};
let decrement = () => {
  i--;
  return i;
};

const importObject = {
  js: {
    // tableの初期値はnull 2つめのWASMモジュールのために設定される
    tbl: null,
    // JSのincrement関数
    increment: increment,
    decrement: decrement,
    // 初期値はnull 2つめのWASMモジュールで作成された関数が設定される
    wasm_increment: null,
    wasm_decrement: null,
  },
};

async () => {
  let table_exp_obj = await WebAssembly.instantiate(
    new Uint8Array(export_bytes),
    importObject
  );
};
