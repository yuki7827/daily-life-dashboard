# Routine実行時の指示

このリポは Claude Code Routines により毎朝6:30 JSTに自動実行され、当日の生活ダッシュボードを生成・公開する。

## あなたの役割

実行日（JST）の生活ダッシュボードを `_posts/YYYY-MM-DD-daily.md` として生成し、main ブランチにコミット＆プッシュする。

## 厳守ルール

- **書き込み可能**: `_posts/`, `index.md`（必要時のみ）, `archive.md`（必要時のみ）
- **書き込み禁止**: `CLAUDE.md`, `_config.yml`, `_layouts/`, `data/`, `README.md`
- **アクセス可能URL**: `data/sources.yml` に列挙されたURLのみ
- **機密情報・APIキー・個人情報は一切扱わない／生成物に含めない**
- 各セクションは**取得失敗時は「（情報取得できず）」と短く記載してスキップ**。途中で止まらない
- 生成された情報には必ず**取得元URLか「(出典: 〜)」表記**を添える

## 実行フロー

### 1. 実行日と居住地の判定
- JSTの今日の日付を取得（`TZ=Asia/Tokyo date +%F`）
- `data/config.yml` の `location_switch_date` と比較
  - 今日 < 切替日 → `hachimanyama`（八幡山）
  - 今日 ≥ 切替日 → `fujimino`（ふじみ野）
- 該当ロケーションの `weather_area_code` 等を保持

### 2. 各セクションの情報収集（順序通り）

すべて `data/sources.yml` を参照。各セクションは独立して try/skip。

**(1) 天気・洗濯・花粉**
- 気象庁JSON（locations別の `weather_area_code` に対応するJSON URL）から最高/最低気温、降水確率、天気概況を抽出
- `tenki.jp` から洗濯指数を取得（取得できなければ降水確率から推定: 30%未満=◎、30-60%=△、60%以上=×）
- 花粉飛散レベルを取得（時期外＝オフシーズン表記）

**(2) スーパー特売・チラシ**
- 該当ロケーションの `supermarkets` 各店舗ページをWebFetchし、本日の目玉商品3〜5件を箇条書き
- 価格と商品名を簡潔に。長文の引用は避ける

**(3) ファミレス・外食キャンペーン**
- `restaurants` 各社の最新キャンペーン/期間限定メニューを1〜2件ずつ
- 「対象期間」「割引/特典内容」を明記

**(4) 今日の献立提案**
- (2)の特売と(1)の天気を踏まえ、夕食案を2パターン
- 各案に「主菜・副菜・汁物」と「不足する買い物リスト」

**(5) ゴミ収集（当日／明日）**
- `garbage` の自治体ページを参照
- 当日と翌日の収集品目を記載
- 曜日判定は厳密に。不明確なら「（要確認）」と明記

**(6) 近隣イベント**
- `events` 各URLから今日〜今週末のイベント・新店オープンを2〜3件

### 3. 出力ファイル生成

`_posts/YYYY-MM-DD-daily.md` を以下のfront matterで作成：

```yaml
---
layout: post
title: "YYYY年M月D日の朝のダッシュボード"
date: YYYY-MM-DD 06:30:00 +0900
location: "（locationのlabel）"
---
```

本文はMarkdown。各セクションは `## 1. 天気・洗濯・花粉` のようにナンバリングしたh2見出しで開始。

末尾に「## ⚙ 取得状況」セクションを設け、各セクションの取得成否を一覧で記録。

### 4. コミット・プッシュ

- `git add _posts/YYYY-MM-DD-daily.md`
- 既存の同日付ファイルがあれば上書き
- コミットメッセージ: `daily: YYYY-MM-DD dashboard`
- `git push origin main`

## 失敗時の挙動

- 情報取得が全滅した場合でも、空のセクション付きでファイルを生成して push する（途中失敗を見える化）
- gitプッシュ自体に失敗した場合のみエラー終了

## 開発時の確認

ローカルで動作を試したいとき：
- `bundle exec jekyll serve` でプレビュー
- `_posts/YYYY-MM-DD-daily.md` を手書きしてレイアウト確認も可

## 参考

- セットアップガイド: https://github.com/yuki7827/claude-code-ios-daily/blob/main/docs/routine-setup-guide.md
