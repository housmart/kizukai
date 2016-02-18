# Kidukai

## Contributors

- Akihisa Miyanaga
- Tomoaki Takamatsu
- Tatsuya Ishisaka
- Daiki Nabuchi
- Yuhei Shimizu
- Hiroki Matsue

## ディレクトリ構成

- bin -> script入れるところ    
- conf -> 設定ファイルあればここ  
- data -> アウトプットをscript_nameディレクトリ以下に置く  
- work -> 中間データとかデータ置きたい場合はscript_nameディレクトリ以下に置く  
- log -> 吐きたければどうぞ

## スクリプトの使い方・説明
```
bin/image_getter.rb
bin/image_splitter.rb
bin/clarifai_client.rb
```

### image_splitter.rb

実行前のディレクトリ構成

```
data/image_getter
├── 1455340062.jpg
└── 1455340128.jpg
```

実行後のディレクトリ構成

```
data/image_getter
├── split
│   ├── 1455340062
│   │   ├── 1455340062-0.jpg
│   │   ├── 1455340062-1.jpg
│   │   ├── 1455340062-2.jpg
│   │   └── 1455340062-3.jpg
│   ├── 1455340128
│   │   ├── 1455340128-0.jpg
│   │   ├── 1455340128-1.jpg
│   │   ├── 1455340128-2.jpg
│   │   └── 1455340128-3.jpg
└── trash
    ├── 1455340062.jpg
    └── 1455340128.jpg
```

### image_splitter.sh

縦に画像を4分割するスクリプト

- 引数1: 元画像のファイルパス
- 引数2: 出力ファイルパス

```
bin/image_splitter.sh tmp/sample.JPG tmp/split.jpg
```

分割されたファイル名には以下のように、suffixが付与される

```
ls tmp
sample.JPG split-0.jpg split-1.jpg split-2.jpg split-3.jpg
```
