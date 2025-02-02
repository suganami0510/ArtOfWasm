## 3章 関数とテーブル
### 概要
- JSや他のWebAssemplyモジュールからどのようなときにどのようにして関数をインポートするのか
- WebAssemplyの関数を組み込み環境にエクスポートし、JSから呼び出すにはどのようにしたら良いのか
  - パフォーマンスの影響についても調査

- WebAssemplyモジュールの中で定義された関数を呼び出す場合よりも、インポートされたJS関数を呼び出す場合のほうが消費サイクルが多い

### 3.1 WATから関数を呼び出す状況
- JSに制御を戻す前にWATコードでできるだけ多くの処理を済ませるようにするのがポイント
  - ループを使って大量のデータを処理

### 3.2 is_prime関数
- 素数かどうか判定 -> リソース食うのでWebAssemblyに最適

### 3.3 インポートする関数宣言
- JS内の名前とWebAssemblyにインポートする名前は同じである必要がある
#### 3.3.1 JSの数値
- JSのコールバック関数を作成する際、その関数で受け取れるデータ型はJavaScriptの数値だけ

#### 3.3.2 データ型の受け渡し
- WebAssenblyがJSからインポートした関数に渡せるのは、32ビット整数 i32 32ビット浮動小数 f32 64ビット浮動小数 f64 のみ
- 他の型を使いたい場合は、型変換をWebAssemblyモジュール内で行う必要がある

#### 3.3.3 WATのオブジェクト
- OOPはサポートしていない
- 線形メモリ内でよりコードなデータ構造を作成する方法(6章)
  - C C++の `struct` と同じようなことを実現させる

### 3.4 外部関数の呼び出しがパフォーマンスに与える影響
- WATでJS関数を呼び出すと、オーバーヘッドとして、計算サイクルが消費される
- loopとかはJSのを使わないほうが良い

```
  // インクリメント4000000回の実行結果
  // wasm_call time=7
  // js_call time=20 -> jsの外部関数を呼び出している分のオーバーヘッド
```

### 3.5 関数テーブル
- 現時点ではWASMのテーブルに追加できるのは関数だけ
- 関数テーブルの関数を呼び出すとパフォーマンスコストが発生する
