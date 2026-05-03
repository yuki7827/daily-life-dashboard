---
layout: default
title: 最新ダッシュボード
---

{% assign latest = site.posts.first %}
{% if latest %}
<meta http-equiv="refresh" content="0; url={{ latest.url | relative_url }}">
<p><a href="{{ latest.url | relative_url }}">{{ latest.title }}</a> へ移動します…</p>
{% else %}
<h1>朝のダッシュボード</h1>
<p>まだ投稿がありません。Routineが初回実行されるとここに今日のダッシュボードが表示されます。</p>
{% endif %}
