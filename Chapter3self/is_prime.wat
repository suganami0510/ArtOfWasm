(module
  (func $even_check (param $n i32) (result i32)
    local.get $n
    i32.const 2
    i32.rem_u   ;; 2で割ったあまりを使う
    i32.const 0 ;; 偶数のあまりは0になる
    i32.eq      ;; $n / 2 == 0
  )

  (func $multiple_check (param $n i32) (param $m i32) (result i32)
    local.get $n
    local.get $m
    i32.rem_u ;; $n % %m
    i32.const 0
    i32.eq ;; $n % %m == 0 なら $n が $m の倍数
  )

  ;; エクスポートを前提とした関数 WebAssemblyモジュール内部で使うラベルがない
  ;; 内部で使うときは以下のような書き方
  ;; (func $is_prime (export "is_prime") (param $n i32) (result i32) ...
  (func (export "is_prime") (param $n i32) (result i32)
    (local $i i32) ;; ループカウンタとしてつかうローカル変数
    (if (i32.eq (local.get $n) (i32.const 1))
      (then
        i32.const 0
        return
      )
    )
    ;; $n が2 かどうか調べる
    (if (i32.eq (local.get $n) (i32.const 2))
      (then
        i32.const 1 ;; 2は素数
        return
      )
    )

    (block $not_prime
      (call $even_check (local.get $n))
      br_if $not_prime ;; (2以外の偶数は素数ではない)

      (local.set $i (i32.const 1))

      (loop $prime_test_loop
        (local.tee $i
          (i32.add (local.get $i) (i32.const 2))) ;; $i += 2 local.teeはスタックの値を先頭からポップせずに残す
        
        local.get $n ;; stack = [$n, $i]

        i32.ge_u ;; $i >= $n
        if
          i32.const 1 ;; $i >= $n の場合 $nは素数
          return
        end

        (call $multiple_check (local.get $n) (local.get $i))

        br_if $not_prime ;; 割り切れる場合は素数ではない
        br $prime_test_loop ;; ループ先頭に戻る
      ) ;; $prime_test_loop Finish
    ) ;; $not_prime Finish

    i32.const 0 ;; falseを返す
  )
) ;; モジュールの終わり
