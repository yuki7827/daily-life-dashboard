# daily-life-dashboard

朝6:30 JSTに自動更新される生活ダッシュボード。Claude Code Routines（クラウドVM）が日次実行し、結果を `_posts/` に追記、GitHub Pagesで公開する。

## 構成セクション

1. 今日の天気・洗濯指数・花粉
2. スーパー特売・チラシ
3. ファミレス・外食キャンペーン
4. 今日の献立提案
5. ゴミ収集（当日/翌日）
6. 近隣イベント

## 居住地切替

- 〜2026-05-21: 東京都世田谷区八幡山
- 2026-05-22〜: 埼玉県ふじみ野市

切替日と参照URLは `data/config.yml` / `data/sources.yml` で管理。

## 仕組み

```
Routine (cron: 30 21 * * * UTC = 06:30 JST)
  → クラウドVMがリポをclone
  → CLAUDE.mdの指示で各セクションを取得・要約
  → _posts/YYYY-MM-DD-daily.md を生成
  → main にcommit & push
  → GitHub Pages が自動ビルド・公開
```

参考: https://github.com/yuki7827/claude-code-ios-daily/blob/main/docs/routine-setup-guide.md
