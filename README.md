# jiikko/homebrew-tap

jiikko の個人ツール用 Homebrew tap。

**このリポジトリが formula の唯一の正本です。** 各ツールのリポジトリに写しは置いていません
（同じものが 2 箇所にあると、片方だけ直したときに静かにずれるため）。

## インストール

```bash
brew install jiikko/tap/<formula>
```

Homebrew が第三者 tap の信頼を求める場合（Homebrew 6 以降）は、先に信頼する:

```bash
brew trust jiikko/tap                        # tap 全体
brew trust --formula jiikko/tap/<formula>    # formula 単位
```

master / main の先端を試すなら `brew install --HEAD jiikko/tap/<formula>`。
いずれも Go 等の build 依存は Homebrew が自動で入れる。

## Formulae

| formula | コマンド | 内容 | リポジトリ |
|---|---|---|---|
| `chrome-slack-cli` | `slack` | Chrome のログインセッションを流用して Slack を読む**読み取り専用** CLI（macOS 専用） | [jiikko/slack-cli](https://github.com/jiikko/slack-cli) |
| `esa` | `esa` | Chrome のログインセッションを流用して esa.io を読む読み取り専用 CLI（macOS 専用） | [jiikko/esa-cli](https://github.com/jiikko/esa-cli) |
| `nrql` | `nrql` | New Relic に NRQL クエリを投げる CLI | [jiikko/newrelic-nrql-cli](https://github.com/jiikko/newrelic-nrql-cli) |
| `tt-client` | `tt-client` | ThumbnailThumb の API クライアント（[本体アプリ](https://jiikko.com/thumbnail-thumb/)が起動している必要あり） | — |

### 🚨 `chrome-slack-cli` の名前について

**formula 名とコマンド名が違います。**インストールされるコマンドは `slack` です。

formula 名を `slack-cli` にできないのは、Homebrew 公式 cask に同名の
[Slack CLI](https://docs.slack.dev/tools/slack-cli/)（Slack 社が配布する別ツール）が
あるためです。`brew install slack-cli` と打つとそちらが入ります。

## メンテナンス

新しいバージョンを出すときは、ツール側でタグを打ってから formula の `url` と `sha256` を更新する:

```bash
curl -sL https://github.com/jiikko/<repo>/archive/refs/tags/vX.Y.Z.tar.gz | shasum -a 256
```

formula を編集したら、手元で通ることを確認してから push する:

```bash
brew install --build-from-source jiikko/tap/<formula>
brew test jiikko/tap/<formula>
```

🚨 **`std_go_args` は既定でバイナリ名に formula 名を使う。** formula 名とコマンド名が違う
場合は `output: bin/"<コマンド名>"` を明示すること（`chrome-slack-cli` で実際に踏んだ）。

## ライセンス

各ツールのライセンスはそれぞれのリポジトリを参照。
