## Chap7 Webアプリケーション
### やること
1. Node.jsを使ってシンプルな静的Webサーバーを用意
2. HTMLの入力要素から数値を受け取り、その値をWebAseemblyに渡して16進数10進数2進数を渡す文字列に変換

### WebAssemblyベースのWebアプリケーション
- WebAssemblyモジュールを読み込んでインスタンス化して、このモジュールの関数を呼び出す(wasmで実行)
- これらのWebアプリケーションは、それらのモジュールから受け取ったデータをDOMに書き込む

### 7.1 DOM
- WASM1.0にはDOMを直接操作する方法がない HTMLドキュメントに対する変更はすべてJSで行う
- wasm-pack Emscriptenなどのツールを使っている場合、JSのグルーコードからDOM操作

### 7.2 シンプルなNodeサーバーセットアプ
- connect
- serve-static

### 7.3
WASM上ではDOM操作ができないので、DOM操作用のJSの関数をimportして、呼び出す必要がある