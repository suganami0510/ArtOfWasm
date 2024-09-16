## 第⑥章 線形メモリ

線形メモリ => WASMとJSの間で共有できる1つの巨大なデータ配列のようなもの
- 低レベルだとネイティブアプリのヒープメモリのようなもの
- JSだとでかいArrayBufferオブジェクトのようなもの

WASMの線形メモリは `ページ` とよばれる大きなチャンク単位で確保される、一度確保したページは開放できない
WASMモジュールに割り当てられたページのメモリが何に使われていて、どこにあるのかを追跡する責任はプログラマにある。

### 6.1.1 ページ
- ページはWASMモジュールに割り当てることができる最も小さなデータチャンク
  - 64KB
  - 1.0ではサイズは変えられない
  - ページの最大数は32,767 全体で2GBのメモリ

### 6.1.2 ポインタ
- WASMのポイントの振る舞い
  - C C++のローカル変数やヒープ上の変数を指しているポインタとは異なる
  - WASMの線形メモリは大きなデータ配列
  - WATでポインタを表すときはデータを線形メモリに配置する
  - ポインタはそのデータに対するi32型のインデックスとなる
  - ローカル変数やグローバル変数に対するポインタを作成することはできない
  - WASMでCのポインタのような機能が必要になった場合は、線形メモリ内の特定のアドレスをグローバル変数に割り当て、このグローバル変数を使ってWASMの線形メモリに格納されている値を設定または取得


### 6.2 メモリオブジェクト
- WASMのメモリオブジェクトを作成、そのデータをWASMモジュールから初期化、そのデータにJSからアクセス
- WASMと組み込み環境(JS)から線形メモリにアクセスする。
- WASMモジュールが初期化される前に線形メモリをJSで定義してアクセスできる、WASMでは線形メモリをJSからインポート

### 6.3 衝突検出
- 線形メモリ内のオブジェクトを構造化するために、ベースアドレス、ストライド、オフセットの組合せを使います。


### 6.3.1 ベースアドレス、ストライド、オフセット
- データ構造体を要素とする配列を作成したい場合は、その要素について次の情報を知っている必要がある
  - 開始アドレス
  - ストライド: 各構造体の間の距離(バイト単位)
  - オフセット: 構造体内のどこからその属性か

### 6.4 まとめ
WASMの線形メモリ
- 線形メモリのデータをWebAssemblyモジュールから初期化して、そのデータにアクセス
- ベースアドレス、ストライド、属性オフセットを使って線形メモリ内にデータ構造体を作成 JSからランダムなデータを使ってそれらの構造体を初期あk
- 