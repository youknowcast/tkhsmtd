
# 高橋メソッド プレゼンテーションビューア

シンプルな高橋メソッド形式のプレゼンテーションを作成・表示するためのツールです。

## 特徴

- YAMLファイルでプレゼンテーションを作成
- 画面サイズに応じて自動的にフォントサイズを調整
- シンプルなキーボード操作
- 複数のプレゼンテーションを一括でHTML化

## インストール

```bash
git clone [このリポジトリのURL]
cd [プロジェクトディレクトリ]
chmod +x bin/present
```

## 使用方法

1. `scripts` ディレクトリにYAMLファイルを作成します

```yaml
title: "プレゼンテーションのタイトル"
presenter: "発表者名"
slides:
  - "1枚目のスライド"
  - "2枚目の\nスライド"
  - "3枚目のスライド"
```

2. プレゼンテーションを生成します

```bash
bin/present
```

3. `slides` ディレクトリに生成されたHTMLファイルをブラウザで開きます

### HTMLの生成

```bash
bin/present
```

### PDFの生成（オプション）

```bash
bundle install  # 初回のみ
bin/generate_pdf
```

## スライド操作

- 次のスライド: 右矢印キー または スペースキー
- 前のスライド: 左矢印キー
- 最後のスライドで停止します

## ディレクトリ構造

```
.
├── bin/
│   └── present           # 実行ファイル
├── lib/
│   └── presenter.rb      # プレゼンテーション生成ロジック
├── templates/
│   └── slide.html.erb    # HTMLテンプレート
├── scripts/              # YAMLファイルを配置
│   └── example.yml
└── slides/              # 生成されたHTMLファイルの出力先
    └── example.html
```

## 制限事項

- 1スライドあたり最大3行まで表示可能
- テキストは自動的に折り返されます
- 画像の表示には対応していません

