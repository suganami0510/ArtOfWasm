(module
  (memory 1) ;; 1ページの線形メモリ作成
  (global $pointer i32 (i32.const 128))

  (func $init
    (i32.store
      (global.get $pointer) ;; $pointerのいちに収納
      (i32.const 99) ;; 収納する値
    )
  )

  (func (export "get_ptr") (result i32)
    (i32.load (global.get $pointer)) ;;pointerの位置にある値を返す => Cのポインタのような機能
  )

  (start $init) ;; $initをモジュールの初期化関数として呼び出す
)