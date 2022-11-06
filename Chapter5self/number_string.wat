;; 数値データを文字列に変換する関数を作成 10進数,16進数,2進数で表された整数から文字列を作成する

(module
  (import "env" "print_string" (func $print_string (param i32 i32)))
  (import "env" "buffer" (memory 1))

  (data (i32.const 128) "0123456789ABCDEF") ;; 本文中の$digits 16進数をすべて含む文字列
	(data (i32.const 256) " 0") ;; 本文中の$dec_string 文字列データを保持するための文字配列
  (global $dec_string_len i32 (i32.const 16)) ;; 文字列の長さを示すグローバル変数

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
  )
)