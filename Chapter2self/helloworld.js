const fs = require('fs');
const bytes = fs.readFileSync(__dirname + '/helloworld.wasm');

let hello_world = null; // 関数は後で設定
let start_string_index = 100; // 線形メモリでの文字列の位置
// MemoryオブジェクトはWebAssemblyインスタンスがアクセスする線形メモリ(バッファ)を表す。
// 1ページ確保
let memory = new WebAssembly.Memory({ initial: 1 }); // 線形メモリ

let importObject = {
	env: { // WebAssemblyのインポート宣言内の名前と一致させる
		buffer: memory,
    start_string: start_string_index,
    print_string: function(str_len) {
      const bytes = new Uint8Array(memory.buffer, start_string_index, str_len);
      const log_string = new TextDecoder('utf8').decode(bytes);
      console.log(log_string);
    }
	}
};

(async() => {
  let obj = await WebAssembly.instantiate(new Uint8Array(bytes), importObject);
  ({ helloworld: hello_world } = obj.instance.exports); // Webassenbryのhelloworld関数を hello_world変数に格納
  hello_world(); // 実行
})();