(module
  ;; jsのincrement decrement 関数
  (import "js" "increment" (func $js_increment (result i32)))
  (import "js" "decrement" (func $js_decrement (result i32)))

  ;; 4つの関数を持つテーブルをエクスポート
  (table $tbl (export "tbl") 4 anyfunc) ;; WATコード内で $tb1が参照可能 anyfunc型のオブジェクトを4つ含んでいる(現時点でテーブルオブジェクトが唯一サポートしている型)
  (global $i (mut i32) (i32.const 0))

  (func $increment (export "increment") (result i32)
	(global.set $i (i32.add (global.get $i) (i32.const 1))) ;; $i++
  global.get $i
  )
  (func $decrement (export "decrement") (result i32)
	(global.set $i (i32.sub (global.get $i) (i32.const 1))) ;; $i--
  global.get $i
  )

  ;; テーブルに関数を追加
  ;; elem式の１つ目のパラメータは最初に追加する要素のインデックス
  (elem (i32.const 0) $js_increment $js_decrement $increment $decrement)

  ;; 最初に要素を2つあとから2つ追加したい場合は以下のように書く
  ;; (elem (i32 const 0) $js_increment $js_decrement)
  ;; (elem (i32 const 2) $increment $decrement)
)