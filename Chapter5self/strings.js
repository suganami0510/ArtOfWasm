const fs = require('fs');
const bytes = fs.readFileSync(__dirname + '/strings.wasm');
const max_mem = 65535; // ①

let memory = new WebAssembly.Memory({ initial: 1 });

let importObject = {
  env: {
    buffer: memory,
    str_pos_len: function (str_pos, str_len) {
      const bytes = new Uint8Array(memory.buffer, str_pos, str_len);
      const log_string = new TextDecoder('utf8').decode(bytes); // バイト配列を文字列に変換
      console.log(log_string);
    },
    null_str: function (str_pos) {
      let bytes = new Uint8Array(memory.buffer, str_pos, max_mem - str_pos);
      let log_string = new TextDecoder('utf8').decode(bytes);
      log_string = log_string.split('\0')[0];
      console.log(log_string);
    },
    len_prefix: function (str_pos) {
      const str_len = new Uint8Array(memory.buffer, str_pos, 1)[0]; // 1バイト目を取り出して定数に保存
      const bytes = new Uint8Array(memory.buffer, str_pos + 1, str_len); // 1バイト目が文字列の長さとして保存されているので、そのバイト数
      let log_string = new TextDecoder('utf8').decode(bytes);
      console.log(log_string);
    },
  },
};

(async () => {
  let obj = await WebAssembly.instantiate(new Uint8Array(bytes), importObject);
  let main = obj.instance.exports.main;
  main();
})();
