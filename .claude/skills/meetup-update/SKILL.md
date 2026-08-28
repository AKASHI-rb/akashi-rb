---
name: meetup-update
description: トップページ (src/index.md) の "Next Event" セクションを、Connpass の最新の AKASHI.rb Meetup 情報に更新する。「meetup情報更新して」「次回イベント更新」「Next Event を最新にして」などと言われたときに使う。
---

# Meetup 情報の更新

`src/index.md` の "Next Event" セクションに載っている開催回番号と Connpass のイベント URL を、
Connpass 上の最新情報に合わせて更新する。

## 手順

### 1. Connpass から対象イベントを特定する

WebFetch で https://akashi-rb.connpass.com/ を取得し、イベント一覧（タイトル・開催日・イベント URL）を集める。

対象イベントの選び方:

- タイトルが **`AKASHI.rb Meetup #XX`** 形式のものだけを候補にする。
  「(ミラー会場) Kansai Ruby Conference」のような、この形式でないイベントは対象外。
  「AKASHI.rb Meetup #14 〜今年の振り返りLT〜」のようにサブタイトルが付いていても、
  先頭が `AKASHI.rb Meetup #XX` なら候補に含める。
- 候補の中から、**開催日が今日に最も近いもの**を選ぶ。
  「開催予定」に候補があればその中で最も日付が近いものを選び、
  「開催予定」に候補が1件も無い場合のみ、直近に終了したものを選ぶ。
- 今日の日付はシステムコンテキストの `Today's date` を使う。

WebFetch の結果が曖昧・不完全なときは、番号・日付・URL の対応が確定するまで
プロンプトを変えて取り直す。推測で URL を組み立てないこと（イベント ID は連番ではない）。

### 2. src/index.md を更新する

`src/index.md` の `<section class="section next-event">` 内、2箇所だけを書き換える:

```html
          次回、AKASHI.rb #22 の開催が決定しました！<br>
```
```html
        <a href="https://akashi-rb.connpass.com/event/403363/" class="btn btn-primary" target="_blank" rel="noopener">
```

前者は `<p class="event-headline">` の中、後者は `<div class="event-actions">` の中にある。

- 見出し文の `#XX` を新しい開催回番号に（サイト表記は `AKASHI.rb #22` で、`Meetup` は入れない）。
- `href` を新しいイベント URL に。末尾のスラッシュ込みで統一する。
- 文言・クラス・その他のセクションは変更しない。

すでに最新の内容になっている場合は、何も変更せずその旨を伝えて終了する。

### 3. 差分を確認して報告する

`git diff src/index.md` で、変更が上記2行だけであることを確認してから報告する。
「#XX → #YY、URL → …」の形で、何をどう変えたかを簡潔に伝える。

## PR まで依頼された場合

このリポジトリの慣例:

- ブランチは `origin/main` から切る（`git checkout -b meetup-NN origin/main`）。
  作業ブランチに未マージのコミットが乗っていると PR に巻き込まれるため、必ず `origin/main` 起点にする。
- コミットメッセージは `meetup #NN`（過去のコミット例: `meetup #17`, `meetup #22`）。
- PR タイトルも `meetup #NN`、base は `main`。

`main` への push で GitHub Actions がデプロイするため、`output/` などのビルド成果物はコミットしない。
