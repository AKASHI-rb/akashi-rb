# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要

兵庫県明石市のRubyコミュニティ「AKASHI.rb」の公式サイト。**Bridgetown 2.2**（Ruby製静的サイトジェネレータ）と esbuild / PostCSS で構築されている。本文コンテンツは日本語、ページタイトルとナビゲーションのラベルは英語。

公開先は https://akashi-rb.com （GitHub Pages）。

## コマンド

```sh
bundle install && npm install     # 初回セットアップ（.ruby-version は 4.0.1、Node は 22 以上）

bin/bridgetown start              # 開発サーバー localhost:4000（Puma/Roda + esbuild watch + ライブリロード）
bin/bridgetown console            # サイトをロードした状態の IRB
bin/bridgetown deploy             # clean + esbuild ビルド + サイト全体を output/ にビルド
bundle exec rake test             # BRIDGETOWN_ENV=test でビルド
```

`bin/bridgetown` と `bin/bt` は binstub。グローバルにインストールされた `bridgetown` ではなくこちらを使うこと（Gemfile のバージョンが使われる）。テストスイートもリンターも設定されていないため、変更の確認は開発サーバーの起動かビルドで行う。

## デプロイ

`.github/workflows/gh-pages.yml` が `main` への push ごとに `BRIDGETOWN_ENV=production` で `bin/bridgetown deploy` を実行し、`output/` を GitHub Pages にアップロードする。`output/` は gitignore 対象なので、ビルド成果物をコミットしないこと。

## アーキテクチャ

- `config/initializers.rb` — サイト全体の設定（URL、`template_engine "erb"`、タイムゾーン、`bridgetown-seo-tag` の init）。開発サーバーでは**自動リロードされない**ので、編集したらサーバーを再起動する。
- `bridgetown.config.yml` — front matter のデフォルト値のみ（OGP 画像の既定値 `image`）。その他の設定は上記の initializer 側にある。
- `src/_data/site_metadata.yml` — リロードされるメタデータ。title、description、`gtm_id`（Google Tag Manager）、favicon。テンプレートからは `site.metadata.*` で参照する。
- `src/_layouts/default.erb` — ルートレイアウト。`_head` パーシャル、GTM の noscript、`Shared::Navbar` コンポーネント、`<main><%= yield %></main>`、`_footer` パーシャルで構成。`page.erb` / `post.erb` はこれをラップして `data.title` を `<h1>` として出力する。
- `src/_components/shared/navbar.rb` + `.erb` — `Bridgetown::Component`（Ruby クラスと同名の ERB テンプレートのペア）。ナビゲーションのリンクはここにベタ書きされているため、ページを追加する際はこのファイルも編集する。
- `plugins/builders/tailwind_jit.rb` — `SiteBuilder` のサブクラス。fast refresh 時に `frontend/styles/jit-refresh.css` を書き換えて Tailwind / esbuild の再ビルドを強制する。このファイルは自動生成かつ gitignore 対象。
- `server/roda_app.rb` — 開発サーバーを支える Roda アプリ。initializer では SSR も `bridgetown-routes` もコメントアウトされているため、現状サイトは完全に静的。

### コンテンツページ

トップレベルのページ（`src/index.md`、`venue.md`、`organizers.md`、`code-of-conduct.md`、`stats.md`）は Markdown ファイルだが、中身は Markdown の文章ではなく生の HTML セクション（`<section class="section">…`）で書かれている。ページを追加するときもこの書き方に合わせ、`navbar.erb` にリンクを追加すること。

定期的に発生する編集は `src/index.md` の "Next Event" セクション（開催回の番号と Connpass のイベント URL）の更新。コミット "meetup #17" などが該当する。この更新は `.claude/skills/meetup-update/SKILL.md`（スキル `meetup-update`）に手順化してある。

### スタイル

`frontend/styles/index.css` が唯一のスタイルシート。`jit-refresh.css` と `tailwindcss` を import した上で、デザインシステム全体を素の CSS で定義している（CSS 変数 `--body-background` / `--action-color` など、`.hero`、`.btn` / `.btn-primary` / `.btn-secondary`、`.section`、`.features`、`.organizer-*`）。Tailwind は利用可能だが、実際のサイトはほぼ手書き CSS なので、ユーティリティクラスを並べるのではなく既存のクラス設計に合わせること。ページ固有のスタイルは、そのページ末尾の `<style>` ブロックに書かれている場合がある（例: `src/venue.md`）。

`esbuild.config.js` が編集用の設定ファイル。`config/esbuild.defaults.js` は Bridgetown が管理していて `bridgetown esbuild update` で再生成されるため、編集しないこと。
