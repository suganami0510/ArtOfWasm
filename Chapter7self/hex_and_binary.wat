(module
  (import "env" "buffer" (memory 1))

  ;; 16進数の数字
  (global $digit_ptr i32 (i32.const 128))
  (data (i32.const 128) "0123445678ABCDEF")

  ;; 10進数文字列のポインタ、長さ、データセクション
  (global $dec_string_ptr i32 (i32.const 256)) ;; 10進数ポインタ
  (global $dec_string_len i32 (i32.const 16)) ;; 文字列の長さを示すグローバル変数
  (data (i32.const 256) " 0") ;; 本文中の$dec_string 文字列データを保持するための文字配列

  ;; 16進数文字列のポインタ、長さ、データセクション
  (global $hex_string_ptr i32 (i32.const 384)) ;; 16進数文字の個数
  (global $hex_string_len i32 (i32.const 16)) ;; 文字列の長さを示すグローバル変数
  (data (i32.const 384) " 0x0") ;; 16進数文字列データ

  ;; 2進数文字列のポインタ、長さ、データセクション
  (global $bin_string_ptr i32 (i32.const 512))
  (global $bin_string_len i32 (i32.const 40))
  (data (i32.const 512) " 0000 0000 0000 0000 0000 0000 0000 0000") ;; 本文中の$bin_string

  ;; h1開始タグの文字列ポインタ、長さ、データセクション
  (global $h1_open_ptr i32 (i32.const 640))
  (global $h1_open_len i32 (i32.const 4))
  (data (i32.const 640) "<H1>")

  ;; h1終了タグの文字列ポインタ、長さ、データセクション
  (global $h1_close_ptr i32 (i32.const 656))
  (global $h1_close_len i32 (i32.const 5))
  (data (i32.const 656) "</H1>")

  ;; h4開始タグの文字列ポインタ、長さ、データセクション
  (global $h4_open_ptr i32 (i32.const 672))
  (global $h4_open_len i32 (i32.const 4))
  (data (i32.const 672) "<H4>")

  ;; h4終了タグの文字列ポインタ、長さ、データセクション
  (global $h4_close_ptr i32 (i32.const 688))
  (global $h4_close_len i32 (i32.const 5))
  (data (i32.const 688) "</H4>")

  ;; 出力文字列の長さとデータセクション
  (global $out_str_ptr i32 (i32.const 1024))
  (global $out_str_len (mut i32) (i32.const 0))

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

  (func $byte_copy
    ;; 引数1 コピー元のメモリ位置 引数2 コピー先のメモリ位置 引数3 コピーする文字列の長さ
    (param $source i32) (param $dest i32) (param $len i32)
    (local $last_source_byte i32)
    local.get $source
    local.get $len
    i32.add ;; $source + $len
    local.set $last_source_byte ;; $last_source_byte = $source + $len
    (loop $copy_loop (block $break
      local.get $dest ;; $dest をi32.store8呼び出しで使うためにスタックにプッシュ
      (i32.load8_u (local.get $source)) ;; sourceから1バイト読み取る
      i32.store8 ;; $destに1バイトを収納

      local.get $dest
      i32.const 1
      i32.add
      local.set $dest ;; $dest = $dest + 1

      local.get $source
      i32.const 1
      i32.add
      local.tee $source ;; $source = $source + 1

      local.get $last_source_byte
      i32.eq ;; $source == $last_source_byteならbreak
      br_if $break
      br $copy_loop
    )) ;; end $copy_loop
  )

  ;; 64ビットコピー関数
  ;; 8バイト(64ビット)ずつコピー 8の倍数でないあまりのNバイトについてはバイト単位のコピーとする
  (func $byte_copy_i64
    ;; 引数1 コピー元のメモリ位置 引数2 コピー先のメモリ位置 引数3 コピーする文字列の長さ
    (param $source i32) (param $dest i32) (param $len i32)
    (local $last_source_byte i32)

    local.get $source
    local.get $len
    i32.add

    local.set $last_source_byte

    (loop $copy_loop (block $break
      (i64.store (local.get $dest) (i64.load (local.get $source))) ;; 1度に64ビット(8バイト)のデータを処理する

      local.get $dest
      i32.const 8
      i32.add
      local.set $dest ;; $dest = $dest + 8

      local.get $source
      i32.const 8
      i32.add
      local.tee $source ;; $source = $source + 8

      local.get $last_source_byte
      i32.ge_u
      br_if $break
      br $copy_loop
    )) ;; end $copy_loop
  )

  (func $string_copy
    (param $source i32) (param $dest i32) (param $len i32)
    (local $start_source_byte i32)
    (local $start_dest_byte i32)
    (local $singles i32)
    (local $len_less_singles i32)

    local.get $len
    local.set $len_less_singles ;; 64ビットコピーでコピーできるバイト数 $len_less_singles = $len
    local.get $len
    i32.const 7 ;; 7 2進数の0111
    i32.and ;; 下3ビット以外をマスクする
    local.tee $singles ;; $singlesは$lenの最後の3ビット 1バイトずつコピーしなければいけないバイト数

    if ;; $lenの最後の3ビットが000でない場合 ビット単位でコピー
      local.get $len
      local.get $singles
      i32.sub
      ;; $len_less_singles = $len - $singles
      local.tee $len_less_singles
      local.get $source
      i32.add
      ;; $start_source_byte = $source + $len_less_singless
      local.set $start_source_byte
      local.get $len_less_singles
      local.get $dest
      i32.add
      ;; $start_dest_byte = $dest + $len_less_singles
      local.set $start_dest_byte
      (call $byte_copy (local.get $start_source_byte)
      (local.get $start_dest_byte) (local.get $singles))
    end
    local.get $len
    i32.const 0xff_ff_ff_f8 ;; 最後の3ビット以外はすべて1 1111111111111111 1111111111111111 1111111111111111 1111111111111000
    i32.and                 ;; $lenの最後の3ビットを0に設定
    local.set $len
    (call $byte_copy_i64 (local.get $source) (local.get $dest) (local.get $len))
  )

  ;; 与えられた文字列を出力文字列の最後に追加
  (func $append_out (param $source i32) (param $len i32)
    (call $string_copy
      (local.get $source)
      (i32.add
        (global.get $out_str_ptr)
        (global.get $out_str_len)
      )
      (local.get $len)
    )

    ;; $out_str_lenに$lenを足す
    global.get $out_str_len
    local.get $len
    i32.add
    global.set $out_str_len
  )

  (func (export "setOutput") (param $num i32) (result i32)
    ;; $numの値から10進数文字列を作成
    (call $set_dec_string
      (local.get $num) (global.get $dec_string_len)
    )
    ;; $numの値から16進数文字列作成
    (call $set_hex_string
      (local.get $num) (global.get $hex_string_len)
    )
    ;; $numの値から2進数文字列作成
    (call $set_bin_string
      (local.get $num) (global.get $bin_string_len)
    )

    i32.const 0
    global.set $out_str_len ;; $out_str_len = 0

    ;; <h1>${decimel_string}<h1/> を出力文字列の最後に追加
    (call $append_out (global.get $h1_open_ptr) (global.get $h1_open_len))
    (call $append_out (global.get $dec_string_ptr) (global.get $dec_string_len))
    (call $append_out (global.get $h1_close_ptr) (global.get $h1_close_len))

    ;;<h4>${hexadecimel_string}</h4> を出力文字列の最後に追加
    (call $append_out (global.get $h4_open_ptr) (global.get $h4_open_len))
    (call $append_out (global.get $hex_string_ptr) (global.get $hex_string_len))
    (call $append_out (global.get $h4_close_ptr) (global.get $h4_close_len))

    ;;<h4>${binary_string}</h4> を出力文字列の最後に追加
    (call $append_out (global.get $h4_open_ptr) (global.get $h4_open_len))
    (call $append_out (global.get $bin_string_ptr) (global.get $bin_string_len))
    (call $append_out (global.get $h4_close_ptr) (global.get $h4_close_len))

    global.get $out_str_len
  )
)