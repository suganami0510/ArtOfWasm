;; 数値データを文字列に変換する関数を作成 10進数,16進数,2進数で表された整数から文字列を作成する

(module
  (import "env" "print_string" (func $print_string (param i32 i32)))
  (import "env" "buffer" (memory 1))

  (data (i32.const 128) "0123456789ABCDEF") ;; 本文中の$digits 16進数をすべて含む文字列
	(data (i32.const 256) " 0") ;; 本文中の$dec_string 文字列データを保持するための文字配列
  (global $dec_string_len i32 (i32.const 16)) ;; 文字列の長さを示すグローバル変数

  (global $hex_string_len i32 (i32.const 16)) ;; 16進数文字の個数
  (data (i32.const 384) " 0x0") ;; 16進数文字列データ

  (global $bin_string_len i32 (i32.const 40))
  (data (i32.const 512) " 0000 0000 0000 0000 0000 0000 0000 0000") ;; 本文中の$bin_string

  (func $set_bin_string (param $num i32) (param $string_len i32)
    (local $index i32)
    (local $loops_remaining i32)
    (local $nibble_bits i32)

    global.get $bin_string_len
    local.set $index

    i32.const 8 ;; 32ビットのニブルは8つ
    local.set $loops_remaining ;; 外側のループでニブルを区切る

    ;; スペースを追加するたmの外側のループ
    (loop $bin_loop(block $outer_break ;; 7
      local.get $index
      i32.eqz
      br_if $outer_break ;; $indexが0になったらループ停止

      i32.const 4
      local.set $nibble_bits ;; 各二ブルの4ビット

      ;; 各桁を処理するための内側のループ
      (loop $nibble_loop(block $nibble_break
        local.get $index
        i32.const 1
        i32.sub
        local.set $index ;; $index--

        local.get $num
        i32.const 1
        i32.and
        if ;; 最後の1ビットが1
          local.get $index
          i32.const 49 ;; ASCIIの `1`が49
          i32.store8 offset=512 ;; 512 + $indexに1
        else ;; 最後の1ビットが
          local.get $index
          i32.const 48 ;; ASCIIの `0`が48
          i32.store8 offset=512 ;; 512 + $indexに0
        end

        local.get $num
        i32.const 1
        i32.shr_u ;; 1ビットシフト
        local.set $num ;; セット

        local.get $nibble_bits
        i32.const 1
        i32.sub
        local.tee $nibble_bits
        i32.eqz
        br_if $nibble_break ;; $nibble_bits == 0ならbreak

        br $nibble_loop
      ))

      local.get $index
      i32.const 1
      i32.sub
      local.tee $index
      i32.const 32 ;; ASCIIのスペース文字
      i32.store8 offset=512 ;; スペースを512+$indexに格納
      br $bin_loop
    ))
  )

  (func $set_hex_string(param $num i32) (param $string_len i32)
    (local $index i32)
    (local $digit_char i32)
    (local $digit_val i32)
    (local $x_pos i32)

    global.get $hex_string_len
    local.set $index ;; $indexに16進数の個数を格納

    (loop $digit_loop (block $break
      local.get $index
      i32.eqz
      br_if $break

      local.get $num
      i32.const 0xf ;; 最後の4ビットが1
      i32.and ;; 最後の4ビット以外をマスク

      local.set $digit_val ;; その桁の値は最後の4ビットに含まれている
      local.get $num
      i32.eqz
      if ;; $num == 0の場合
        local.get $x_pos
        i32.eqz
        if
          local.get $index
          local.set $x_pos
        else
          i32.const 32 ;; 32はASCIIのスペース文字
          local.set $digit_char
        end
      else
        ;; 128 + $digit_val(0123456789ABCDEF)から文字を読み込む
        (i32.load8_u offset=128 (local.get $digit_val))
        local.set $digit_char
      end

      local.get $index
      i32.const 1
      i32.sub
      local.tee $index ;; $index = $index - 1

      ;; $digit_charの文字を384 + $indexに格納
      (i32.store8 offset=384 (local.get $index) (local.get $digit_char))
      local.get $num
      i32.const 4
      i32.shr_u ;; $numの16進数を1桁シフト(4ビット右シフト)
      local.set $num

      br $digit_loop
    ))

    local.get $x_pos
    i32.const 1
    i32.sub

    i32.const 120 ;; ascii x
    i32.store8 offset=384 ;; 'x'を文字列に格納

    local.get $x_pos
    i32.const 2
    i32.sub
    i32.const 48 ;; '0'
    i32.store8 offset=384 ;; '0x'を文字列の先頭に格納
  )

  (func $set_dec_string (param $num i32) (param $string_len i32)
    (local $index i32)
    (local $digit_char i32)
    (local $digit_val i32)

    local.get $string_len
    local.set $index ;; indexに文字列の長さを収納

    local.get $num
    i32.eqz ;; $num == 0
    if ;; $num == 0の場合,スペースは不要
      local.get $index
      i32.const 1
      i32.sub
      local.set $index ;; $index--

      ;; ASCIIの'0'をメモリ位置256 + $indexに格納
      (i32.store8 offset=256 (local.get $index) (i32.const 48))
    end

    ;;ループを使って数値を文字列に変換
    (loop $digit_loop (block $break
      ;; $indexが文字列の終わりを指すようにし,0にデクリメント
      local.get $index
      i32.eqz
      br_if $break ;; $index == 0 の場合はループを抜ける

      local.get $num
      i32.const 10
      i32.rem_u ;; 0~9の数字は10で割ったあまり

      local.set $digit_val ;; 10で割ったあまりを格納
      local.get $num
      i32.eqz ;; $numが0かどうかチェック
      if
        i32.const 32 ;; ASCIIのスペース文字
        local.set $digit_char ;; $numが0の場合は左側をスペースでパディング
      else
        (i32.load8_u offset=128 (local.get $digit_val)) ;; 0123456789ABCDEF の$digitsより文字列を取得
        local.set $digit_char ;; $digit_charに取得したASCII数字を格納
      end

      local.get $index
      i32.const 1
      i32.sub
      local.set $index ;; $index--
      ;; ASCII文字を256 + $indexに格納
      (i32.store8 offset=256 (local.get $index) (local.get $digit_char))
      
      local.get $num
      i32.const 10
      i32.div_u ;; 10進数の最後の桁を削除, 10で割る -> ex) 9632 -> 963
      local.set $num

      br $digit_loop
    ))
  )

  (func (export "to_string") (param $num i32)
    (call $set_dec_string
      (local.get $num) (global.get $dec_string_len))
    (call $print_string
      (i32.const 256) (global.get $dec_string_len) ;; 文字列の開始位置, 文字列の長さ
    )
    (call $set_hex_string
      (local.get $num) (global.get $hex_string_len)
    )
    (call $print_string
      (i32.const 384) (global.get $hex_string_len)
    )
    (call $set_bin_string
      (local.get $num) (global.get $bin_string_len)
    )
    (call $print_string
      (i32.const 512) (global.get $bin_string_len)
    )
  )
)