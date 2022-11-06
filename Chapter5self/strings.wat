(module 
  (import "env" "str_pos_len" (func $str_pos_len (param i32 i32))) ;; 第一引数メモリの開始位置、第二引数文字列の長さ
  (import "env" "null_str" (func $null_str (param i32))) ;; メモリのどの位置からスタートすれば良いのかだけわかれば良いので引数1つ
  (import "env" "len_prefix" (func $len_prefix (param i32))) ;; 文字列の1バイト目を調べて文字列の長さを突き止める 第一引数は位置
  (import "env" "buffer" (memory 1))

  (data (i32.const 0) "null-terminating string\00") ;;\00は0の値を持つシングルバイト
  (data (i32.const 128) "anothre null-terminating string\00")
  ;; 30文字
	(data (i32.const 256) "Know the length of this string")
  ;; 35文字
	(data (i32.const 384) "Also know the length of this string")
  ;; 16進数の16 => 22文字
  (data (i32.const 512) "\16length-prefired string")
  ;; 16進数の1e => 30文字
  (data (i32.const 640) "\1eanother length-prefired string")

  (func (export "main")
    ;; (call $null_str (i32.const 0))
    ;; (call $null_str (i32.const 128))
    ;; 1つ目の文字列は30文字
    (call $str_pos_len (i32.const 256) (i32.const 30))
    ;; 2つ目の文字は35文字
    (call $str_pos_len (i32.const 384) (i32.const 35))
    ;; (call $len_prefix (i32.const 512))
    ;; (call $len_prefix (i32.const 640))
    (call $string_copy (i32.const 256) (i32.const 384) (i32.const 30))
    (call $str_pos_len (i32.const 384) (i32.const 35))
    (call $str_pos_len (i32.const 384) (i32.const 30))
  )

  ;; バイト単位のコピー 効率は悪い
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
)