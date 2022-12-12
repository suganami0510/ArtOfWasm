(module
  (import "env" "mem" (memory 1))
  (global $obj_base_addr (import "env" "obj_base_addr") i32) ;; jsからインポート
  (global $obj_count (import "env" "obj_count") i32)
  (global $obj_stride (import "env" "obj_stride") i32)
  ;; 属性のオフセット位置
  (global $x_offset (import "env" "x_offset") i32) ;; x座標　
  (global $y_offset (import "env" "y_offset") i32) 
  (global $radius_offset (import "env" "radius_offset") i32)
  (global $collision_offset (import "env" "collision_offset") i32)

  (func $collision_check
    (param $x1 i32) (param $y1 i32) (param $r1 i32)
    (param $x2 i32) (param $y2 i32) (param $r2 i32)
    (result i32)

    (local $x_diff_sq i32)
    (local $y_diff_sq i32)
    (local $r_sum_sq i32)
    local.get $x1
    local.get $x2
    i32.sub
    local.tee $x_diff_sq
    local.get $x_diff_sq
    i32.mul
    local.set $x_diff_sq ;; ($x1 - $x2) * ($x1 - $x2)
    
    local.get $y1
    local.get $y2
    i32.sub
    local.tee $y_diff_sq
    local.get $y_diff_sq
    i32.mul
      local.set $y_diff_sq ;; ($y1 - $y2) * ($y1 - $y2)  )

    local.get $r1
    local.get $r2
    i32.add
    local.tee $r_sum_sq
    local.get $r_sum_sq
    i32.mul
      local.tee $r_sum_sq ;; ($r1 + r2) * ($r1 + $r2)
    
    local.get $x_diff_sq
    local.get $y_diff_sq
    i32.add ;; ピタゴラスの定理　A^2 + B^2 = C^2

    i32.gt_u ;; 距離が半径の合計よりも小さい場合はtrueを返す
  )

  (func $get_attr (param $obj_base i32) (param $attr_offset i32)
    (result i32)
    local.get $obj_base
    local.get $attr_offset

    i32.add ;; ベースアドレスに属性オフセットを足し
    i32.load ;; その値にある値を読み取って返す
  )

  (func $set_collision
    (param $obj_base1 i32) (param $obj_base2 i32)
    local.get $obj_base1
    global.get $collision_offset
    i32.add ;; アドレス = $obj_base1 + $collision_offset
    i32.const 1
    i32.store ;; このオブジェクトの衝突フラグ属性に1(true)を格納

    local.get $obj_base2
    global.get $collision_offset
    i32.add ;; アドレス = $obj_base2 + $collision_offset
    i32.const 1
    i32.store ;; このオブジェクトの衝突フラグ属性に1(true)を格納
  )

  (func $init
    ;; 外側のループカウンタ
    (local $i i32)
    ;; i番目のオブジェクトのアドレス
    (local $i_obj i32)
    ;; オブジェクトiのx,y,r
    (local $xi i32)(local $yi i32)(local $ri i32)
    ;; 外側のループカウンタ
    (local $j i32)
    ;; j番目のオブジェクトのアドレス
    (local $j_obj i32)
    ;; オブジェクトjのx,y,r
    (local $xj i32)(local $yj i32)(local $rj i32)

    ;; 外側のloop
    (loop $outer_loop
      (local.set $j (i32.const 0)) ;; $j = 0;
      (loop $inner_loop
        (block $innner_continue
          ;; $i == $j の場合は処理をスキップ
          (br_if $innner_continue (i32.eq (local.get $i) (local.get $j)))

          ;; $i_obj = $obj_base_address + $i * $obj_stride
          (i32.add (global.get $obj_base_addr)
          (i32.mul (local.get $i) (global.get $obj_stride)))
          ;; $i_obj + $x_offsetを読み取って$xiに格納
          (call $get_attr (local.tee $i_obj) (global.get $x_offset))
          local.set $xi
          ;; $i_obj + $y_offsetを読み取って$yiに格納
          (call $get_attr (local.get $i_obj) (global.get $y_offset))
          local.set $yi
          ;; $i_obj + $radius_offsetを読み取って$riに格納
          (call $get_attr (local.get $i_obj) (global.get $radius_offset))
          local.set $ri

          ;; $j_obj = $obj_base_addr + $j * $obj_stride
          (i32.add (global.get $obj_base_addr)
          (i32.mul (local.get $j)(global.get $obj_stride)))
          ;; $j_obj + $x_offsetを読み取って$xjに格納
          (call $get_attr (local.tee $j_obj) (global.get $x_offset) )
          local.set $xj
          ;; $j_obj + $y_offsetを読み取って$yjに格納
          (call $get_attr (local.get $j_obj) (global.get $y_offset))
          local.set $yj
          ;; $j_obj + $radius_offsetを読み取って$rjに格納
          (call $get_attr (local.get $j_obj) (global.get $radius_offset))
          local.set $rj

          ;; i番目と j番目のオブジェクトの衝突チェック
          (call $collision_check
          (local.get $xi) (local.get $yi) (local.get $ri)
          (local.get $xj) (local.get $yj) (local.get $rj))
          if ;; 衝突する場合
            (call $set_collision (local.get $i_obj) (local.get $j_obj))
          end
        )

        (i32.add (local.get $j) (i32.const 1)) ;; $j++

        ;; $j < $obj_countの場合はループを繰り返す
        (br_if $inner_loop
        (i32.lt_u (local.tee $j) (global.get $obj_count)))
      )

      (i32.add (local.get $i) (i32.const 1)) ;; $i++
      ;; $j < $obj_countの場合はループを繰り返す
      (br_if $outer_loop
        (i32.lt_u (local.tee $i) (global.get $obj_count)))
    )
  )

  (start $init)
)
