(module
  (import "js" "tbl" (table $tbl 4 anyfunc))
  ;; ijsのncrement decrement関数をインポート
  (import "js" "increment" (func $increment (result i32)))
  (import "js" "decrement" (func $decrement (result i32)))

  ;; wasm_increment wasm_decrement 関数をインポート
  (import "js" "wasm_increment" (func $wasm_increment (result i32)))
  (import "js" "wasm_decrement" (func $wasm_decrement (result i32)))

  ;;テーブル関数の定義はすべてi32である、パラメータはない
  (type $reterns_i32 (func (result i32)))

  ;; JSのincrement decrement関数のテーブルインデックス
  (global $inc_ptr i32 (i32.const 0))
  (global $dec_ptr i32 (i32.const 1))

  ;; WASMのincrement decrement関数のインデックス
  (global $wasm_inc_ptr i32 (i32.const 2))
  (global $wasm_dec_ptr i32 (i32.const 3))

  ;; js関数の間接的な呼び出しのパフォーマンスのテスト
  (func (export "js_table_test")
    (loop $inc_cycle
      ;; JSのincrement関数を間接的に呼び出す
      (call_indirect (type $reterns_i32) (global.get $inc_ptr))
      i32.const 4_000_000
      i32.le_u ;;inc_ptrから返された値は4000000以下か
      br_if $inc_cycle
    )

    (loop $dec_cycle
      ;; JSのincrement関数を間接的に呼び出す
      (call_indirect (type $reterns_i32) (global.get $dec_ptr))
      i32.const 4_000_000
      i32.le_u ;;dec_ptrから返された値は4000000以下か
      br_if $dec_cycle
    ) 
  )

  ;; JS関数を直接呼び出したときのパフォーマンス
  (func (export "js_import_test")
    (loop $inc_cycle
      ;; JSのincrement関数を直接呼び出す
      call $increment
      i32.const 4_000_000
      i32.le_u ;;inc_ptrから返された値は4000000以下か
      br_if $inc_cycle
    )
    (loop $dec_cycle
      ;; JSのdecrement関数を直接呼び出す
      call $decrement
      i32.const 4_000_000
      i32.le_u ;;dec_ptrから返された値は4000000以下か
      br_if $dec_cycle
    )
  )

  ;; WASM関数の間接的な呼び出しのパフォーマンスをテスト
  (func (export "wasm_table_test")
    (loop $inc_cycle
      (call_indirect (type $reterns_i32) (global.get $wasm_inc_ptr))
      i32.const 4_000_000
      i32.le_u
      br_if $inc_cycle
    )

    (loop $dec_cycle
      (call_indirect (type $reterns_i32) (global.get $wasm_dec_ptr))
      i32.const 4_000_000
      i32.le_u
      br_if $dec_cycle
    )
  )

  ;; WASM関数の直接的な呼び出しのパフォーマンステスト
  (func (export "wasm_import_test")
    (loop $inc_cycle
      call $wasm_increment
      i32.const 4_000_000
      i32.le_u
      br_if $inc_cycle
    )
    (loop $dec_cycle
      call $wasm_decrement
      i32.const 4_000_000
      i32.le_u
      br_if $dec_cycle
    )
  )
)