(module 
  (import "env" "str_pos_len" (func $str_pos_len (param i32 i32))) ;; 第一引数メモリの開始位置、第二引数文字列の長さ
  (import "env" "null_str" (func $null_str (param i32))) ;; メモリのどの位置からスタートすれば良いのかだけわかれば良いので引数1つ
  (import "env" "len_prefix" (func $len_prefix (param i32))) ;; 文字列の1バイト目を調べて文字列の長さを突き止める 第一引数は位置
  (import "env" "buffer" (memory 1))
  (data (i32.const 0) "null-terminating string\00") ;;\00は0の値を持つシングルバイト
  (data (i32.const 128) "anothre null-terminating string\00")
  ;; 30文字
  (data (i32.const 256) "Know the length of string")
  ;; 35文字
  (data (i32.const 384) "Also know the length of string")
  ;; 16進数の16 => 22文字
  (data (i32.const 512) "\16length-prefired string")
  ;; 16進数の1e => 30文字
  (data (i32.const 640) "\1eanother length-prefired string")

  (func (export "main")
    (call $null_str (i32.const 0))
    (call $null_str (i32.const 128))
    ;; 1つ目の文字列は30文字
    (call $str_pos_len (i32.const 256) (i32.const 30))
    ;; 2つ目の文字は35文字
    (call $str_pos_len (i32.const 384) (i32.const 35))
    (call $len_prefix (i32.const 512))
    (call $len_prefix (i32.const 640))
  )
)