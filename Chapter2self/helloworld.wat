(module
  ;; 組み込み環境からインポートしたenvが利用できること、print_string関数があることをWebAssemblyに教える
  (import "env" "print_string" (func $print_string(param i32)))
  ;; envオブジェクトからメモリバッファをインポートすること、そのバッファの名前が `buffer` であること (memory 1)はこのバッファが1ページ(64kb)の線形メモリとなること
  (import "env" "buffer" (memory 1))

  ;; $start_stringはJSのインポートオブジェクトからインポートした数値
  (global $start_string (import "env" "start_string") i32) 
  ;; ここで定義する文字列の名側を表す定数
  (global $string_len i32 (i32.const 12))
  ;; データ式を使って線形メモリ内の文字列を定義
  (data (global.get $start_string) "hello world!")
  ;; JSで使う関数を "helloworld" として定義してExport
  (func (export "helloworld")
    ;; インポートした $print_string関数を呼び出し、グローバル変数として定義した文字列の長さを渡す
    (call $print_string(global.get $string_len))
  )
)