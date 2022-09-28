(module
  ;; JS関数の外部からの呼び出し
  (import "js" "external_call" (func $external_call(result i32)))
  ;; 内部関数のためのグローバル変数
  (global $i (mut i32) (i32.const 0)) ;; 初期値0

  (func $internal_call (result i32)
    global.get $i
    i32.const 1
    i32.add
    global.set $i ;; $i ++

    global.get $i ;; $iを呼び出し元の関数に返す
  )

  ;; jsにエクスポートされる"wasm_call"関数
  (func (export "wasm_call")
    (loop $again ;; $againループ
      call $internal_call ;; WASMの$intenral_call関数を呼び出す
      i32.const 4000000
      i32.le_u ;; 4000000以下？
      br_if $again ;; yesであればagainループに戻る
    )
  )

  (func (export "js_call")
    (loop $again
      (call $external_call)
      i32.const 4000000
      i32.le_u ;; 4000000以下？
      br_if $again ;; yesであればagainループに戻る
    )
  )
)