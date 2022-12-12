(module
  (import "env" "mem" (memory 1)) ;; 線形メモリのJSからのインポート
  (global $data_addr (import "env" "data_addr") i32) ;; データのアドレスをインポート
  (global $data_count(import "env" "data_count") i32) ;; モジュールの初期化時に格納するi32型の整数値の個数をインポート

  (func $store_data (param $index i32) (param $value i32)
    (i32.store
      (i32.add
        ;; $data_addrに$index * 4 (i32=4バイト)を足す
        (global.get $data_addr)
        ;; $index * 4
        (i32.mul (i32.const 4) (local.get $index))
      )
      (local.get $value) ;; 格納する値
    )
  )

  (func $init
    (local $index i32)

    (loop $data_loop
      local.get $index

      local.get $index
      i32.const 5
      i32.mul

      call $store_data ;; パラメータ$index, $index * 5 で呼び出し $store_data($index, $index * 5) データを表示するときに値を5づつカウントアップ

      local.get $index
      i32.const 1
      i32.add ;; $index++

      local.tee $index ;; ループのカウントの数
      global.get $data_count ;; データの数に基づいて複数の32ビット整数を設定

      i32.lt_u
      br_if $data_loop
    )

    (call $store_data (i32.const 0) (i32.const 1)) ;; 最初のデータを1にすることで設定されたデータがどこから始まるのかわかるようにする 
  )

  (start $init)
)