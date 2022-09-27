;; WATがアクセスできるのは現在の関数が追加したスタック変数のみ
(module
  (func $inner
    (result i32)
    (local $1 i32)
    local.set $1 ;; 99は呼び出し元の関数のスタックにある

    i32.const 2
  )
  (func (export "main")
    (result i32)

    i32.const 99 ;; 99をスタックにプッシュ - [99]
    call $inner ;; ここで99はスタック上にある 呼び出し元の関数がスタックに配置したデータにはアクセスできないので、パラメータで渡す必要がある。
  )
)